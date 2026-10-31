"""Read-only FAT16/FAT32 locator for root IMAGE.BMP on a full disk image."""
import argparse
import struct

def u16(d, n): return struct.unpack_from('<H', d, n)[0]
def u32(d, n): return struct.unpack_from('<I', d, n)[0]

def locate(path, partition_lba=None, filename='IMAGE.BMP', variable_size=False):
    parts = filename.upper().split('.')
    if (len(parts) != 2 or not 1 <= len(parts[0]) <= 8 or parts[1] != 'BMP'
            or not all(c.isascii() and (c.isalnum() or c == '_') for c in parts[0])):
        raise ValueError('Expected an ASCII 8.3 BMP filename, e.g. IMAGE0.BMP')
    short_name = (parts[0].ljust(8) + parts[1]).encode('ascii')
    with open(path, 'rb', buffering=0) as disk:
        def sec(lba):
            disk.seek(lba * 512); d = disk.read(512)
            if len(d) != 512: raise ValueError('Short disk read')
            return d
        mbr = sec(0)
        if mbr[510:512] != bytes([85, 170]): raise ValueError('Missing MBR signature')
        p = next((446 + i * 16 for i in range(4) if mbr[450 + i * 16] in (6, 11, 12)), None)
        base = partition_lba if partition_lba is not None else (u32(mbr, p + 8) if p is not None else 0)
        b = sec(base); spc, reserved, fats = b[13], u16(b, 14), b[16]
        root_entries, spf16 = u16(b, 17), u16(b, 22)
        if u16(b, 11) != 512 or not spc or spc & (spc - 1) or not fats: raise ValueError('Invalid BPB')
        fatsz = u32(b, 36) if spf16 == 0 else spf16
        root_secs = (root_entries * 32 + 511) // 512
        fat_base = base + reserved; root_base = fat_base + fats * fatsz; data_base = root_base + root_secs
        fat16 = root_entries != 0; found = None
        for lba in range(root_base, root_base + root_secs):
            d = sec(lba)
            for off in range(0, 512, 32):
                e = d[off:off + 32]
                if e[0] == 0: break
                if e[0] == 229 or e[11] & 24 or e[11] == 15: continue
                if e[:11] == short_name: found = (u16(e, 26), u32(e, 28)); break
            if found: break
        if not found: raise ValueError(f'Root {filename} not found')
        first, size = found
        if not variable_size and size != 921654: raise ValueError(f'Unexpected BMP size: {size}')
        def fat_entry(c):
            pos = c * (2 if fat16 else 4); d = sec(fat_base + pos // 512)
            return u16(d, pos % 512) if fat16 else u32(d, pos % 512) & 0x0FFFFFFF
        def clba(c): return data_base + (c - 2) * spc
        count = (size + spc * 512 - 1) // (spc * 512); cluster = first
        for _ in range(count - 1):
            nxt = fat_entry(cluster)
            if nxt != cluster + 1: raise ValueError(f'{filename} is fragmented')
            cluster = nxt
        h = sec(clba(first))
        width, height, offset = u32(h, 18), u32(h, 22), u32(h, 10)
        supported = (1 <= width <= 1280 and 1 <= height <= 1024 and 54 <= offset <= 4096
                     if variable_size else width == 640 and height == 480 and offset == 54)
        if (h[:2] != b'BM' or not supported or u32(h, 14) != 40
                or u16(h, 26) != 1 or u16(h, 28) != 24 or u32(h, 30)):
            raise ValueError('Unsupported BMP header')
        if size != offset + ((width * 3 + 3) & ~3) * height or u32(h, 2) != size:
            raise ValueError('BMP size/header mismatch')
        tail = fat_entry(cluster)
        if tail < (0xFFF8 if fat16 else 0x0FFFFFF8):
            raise ValueError('Unexpected FAT chain tail')
        return clba(first)

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('disk')
    ap.add_argument('--partition-lba', type=int, help='partition start sector, e.g. F: = 245760')
    ap.add_argument('--files', nargs='+', default=['IMAGE.BMP'], help='root 8.3 BMP filenames')
    ap.add_argument('--variable-size', action='store_true', help='Ex3: positive 24-bit BMP up to 1280x1024')
    a = ap.parse_args()
    # Validate the full list before printing addresses, avoiding a partial list
    # that might be mistaken for a complete playlist on a later file error.
    results = [(name, locate(a.disk, a.partition_lba, name, a.variable_size)) for name in a.files]
    for name, lba in results:
        print(f'{name}: IMAGE_LBA = {lba}')
    print('Contiguous FAT16/FAT32 BMP verified. Ex3 derives sector count from header.' if a.variable_size
          else 'SECTORS = 1801; contiguous FAT16/FAT32 BMP verified.')
