"""Read-only FAT16/FAT32 locator for contiguous root VIDEO0.AV files.
Reads a full SD image or Windows physical disk with administrative READ access.
Never opens a disk for writing. Does not assume copied files are contiguous.
"""
import argparse
import json
import struct
from pack_video import validate_header
from pack_video_hq import make_header as hq_header


def u16(b, p): return struct.unpack_from('<H', b, p)[0]
def u32(b, p): return struct.unpack_from('<I', b, p)[0]


def locate(path, filename, partition_lba=None):
    parts = filename.upper().split('.')
    if len(parts) != 2 or not 1 <= len(parts[0]) <= 8 or parts[1] != 'AV':
        raise ValueError('Use an ASCII 8.3 AV filename, e.g. VIDEO0.AV')
    if not all(c.isascii() and (c.isalnum() or c == '_') for c in parts[0]):
        raise ValueError('Invalid short filename')
    name = (parts[0].ljust(8) + parts[1].ljust(3)).encode('ascii')
    with open(path, 'rb', buffering=0) as disk:
        def sec(lba):
            disk.seek(lba * 512)
            b = disk.read(512)
            if len(b) != 512: raise ValueError('Short disk read')
            return b
        m = sec(0)
        if m[510:] != b'\x55\xaa': raise ValueError('Missing boot signature')
        # Distinguish a superfloppy BPB from an MBR before reading partitions.
        superfloppy = u16(m, 11) == 512 and m[13] in (1,2,4,8,16,32,64,128)
        candidates = [u32(m, 454 + i*16) for i in range(4)
                      if m[450+i*16] in (4,6,14,11,12)]
        if partition_lba is None:
            if not superfloppy and len(candidates) != 1:
                raise ValueError('Specify --partition-lba for this disk layout')
            base = 0 if superfloppy else candidates[0]
        else: base = partition_lba
        b = sec(base)
        spc, reserved, fats = b[13], u16(b,14), b[16]
        if (b[510:] != b'\x55\xaa' or u16(b,11) != 512 or
                not spc or spc & (spc-1) or not reserved or not fats):
            raise ValueError('Not a supported FAT16/FAT32 BPB (exFAT unsupported)')
        root_entries, spf16 = u16(b,17), u16(b,22)
        total = u16(b,19) or u32(b,32)
        spf = spf16 or u32(b,36)
        root_secs = (root_entries*32+511)//512
        fat_base = base+reserved
        root_base = fat_base+fats*spf
        data_base = root_base+root_secs
        clusters = (total-(data_base-base))//spc
        if clusters < 4085: raise ValueError('FAT12 is unsupported')
        fat16 = clusters < 65525
        if fat16 != bool(root_entries and spf16): raise ValueError('Inconsistent BPB')
        if not fat16 and u16(b,40) & 128:
            active = u16(b,40) & 15
            if active >= fats: raise ValueError('Invalid active FAT')
            fat_base += active*spf
        def clba(c):
            if not 2 <= c < clusters+2: raise ValueError('Invalid FAT cluster')
            return data_base+(c-2)*spc
        def entry(c):
            p = c*(2 if fat16 else 4)
            d = sec(fat_base+p//512)
            return u16(d,p%512) if fat16 else u32(d,p%512)&0x0fffffff
        def eoc(c): return c >= (0xfff8 if fat16 else 0x0ffffff8)
        def root_sectors():
            if fat16:
                yield from range(root_base, root_base+root_secs)
            else:
                c = u32(b,44)&0x0fffffff
                seen = set()
                while not eoc(c):
                    if c in seen: raise ValueError('Root FAT chain loop')
                    seen.add(c)
                    yield from range(clba(c),clba(c)+spc)
                    c = entry(c)
        found = None
        for lba in root_sectors():
            d = sec(lba)
            for off in range(0,512,32):
                e = d[off:off+32]
                if e[0] == 0: break
                if e[0] == 229 or e[11] & 24: continue
                if e[:11] == name:
                    found = (u16(e,26) | (0 if fat16 else u16(e,20)<<16),u32(e,28))
                    break
            if found or d[off] == 0: break
        if not found: raise ValueError(f'{filename} not found in root directory')
        first,size = found
        h=sec(clba(first))
        if h[:4] in (b'AV10', b'AV15') and h[4:8] == (3).to_bytes(4,'little'):
            frames=u32(h,20)
            packet_bytes=166912
        elif h[:4]==b'AV10':
            frames=u32(h,20)
            if h!=hq_header(frames): raise ValueError('Invalid AV10 header')
            packet_bytes=173056
        else:
            frames=validate_header(h);packet_bytes=51200
        if size != 512+frames*packet_bytes: raise ValueError('AV file size/header mismatch')
        count = (size+spc*512-1)//(spc*512)
        c = first
        for _ in range(count-1):
            nxt = entry(c)
            if nxt != c+1: raise ValueError(f'{filename} is fragmented; FPGA cannot stream it')
            clba(nxt)
            c = nxt
        if not eoc(entry(c)): raise ValueError('File FAT chain has unexpected tail')
        return dict(file=filename,lba=clba(first),frames=frames,sectors=size//512)


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('disk')
    p.add_argument('--partition-lba',type=int)
    p.add_argument('--files',nargs='+',default=['VIDEO0.AV'])
    a = p.parse_args()
    if not 1 <= len(a.files) <= 3: p.error('Provide one to three files in playlist order')
    results = [locate(a.disk,n,a.partition_lba) for n in a.files]
    print(json.dumps(results,indent=2))
    print('Set VIDEO0_LBA / VIDEO1_LBA / VIDEO2_LBA in rtl/hdmi_video_top.v.')
    print('Unused positions default to zero and alias VIDEO0. Rebuild after any SD file changes.')
