import sys
import struct
import tempfile
import unittest
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from pack_video import pack,make_header,validate_header,VIDEO_BYTES,AUDIO_BYTES
from locate_video import locate


class PackTests(unittest.TestCase):
    def test_padding_and_order(self):
        with tempfile.TemporaryDirectory() as td:
            p=Path(td)
            (p/'v').write_bytes(b'\x12\x34'*(VIDEO_BYTES//2)+b'\x56\x78'*(VIDEO_BYTES//2))
            (p/'a').write_bytes(b'\x01\x02\x03\x04')
            info=pack(p/'v',p/'a',p/'out')
            d=(p/'out').read_bytes()
            self.assertEqual(info['sectors'],201)
            self.assertEqual(validate_header(d[:512]),2)
            self.assertEqual(d[512:512+VIDEO_BYTES],(p/'v').read_bytes()[:VIDEO_BYTES])
            self.assertEqual(d[512+VIDEO_BYTES:512+VIDEO_BYTES+8],b'\x01\x02\x03\x04\0\0\0\0')
            self.assertEqual(d[51712:51714],b'\x56\x78')
            self.assertEqual(d[-AUDIO_BYTES:],bytes(AUDIO_BYTES))
            with self.assertRaises(FileExistsError): pack(p/'v',p/'a',p/'out')

    def test_header_rejects(self):
        for offset in (0,4,8,10,12,14,16,24,28,32,511):
            h=make_header(1);h[offset]^=1
            with self.assertRaises(ValueError):validate_header(h)
        with self.assertRaises(ValueError):make_header(0)

    def test_fat16_contiguity(self):
        with tempfile.TemporaryDirectory() as td:
            p=Path(td)/'disk.img'
            # FAT16 superfloppy: reserved=1, FAT=32 sectors, root=1 sector.
            d=bytearray(8192*512)
            struct.pack_into('<H',d,11,512);d[13]=1
            struct.pack_into('<H',d,14,1);d[16]=1
            struct.pack_into('<H',d,17,16);struct.pack_into('<H',d,19,8192)
            struct.pack_into('<H',d,22,32);d[510:512]=b'\x55\xaa'
            for c in range(2,103):struct.pack_into('<H',d,512+c*2,c+1 if c<102 else 0xffff)
            root=33*512;d[root:root+11]=b'VIDEO0  AV '
            d[root+11]=32;struct.pack_into('<H',d,root+26,2)
            struct.pack_into('<I',d,root+28,51712)
            d[34*512:35*512]=make_header(1);p.write_bytes(d)
            self.assertEqual(locate(p,'VIDEO0.AV')['lba'],34)
            struct.pack_into('<H',d,512+4,4);p.write_bytes(d)
            with self.assertRaisesRegex(ValueError,'fragmented'):locate(p,'VIDEO0.AV')


if __name__=='__main__':unittest.main()
