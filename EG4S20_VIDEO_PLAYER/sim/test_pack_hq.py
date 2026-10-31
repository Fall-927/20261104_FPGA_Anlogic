import sys
import tempfile
import unittest
import struct
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from pack_video_hq import make_header,pack,VIDEO_BYTES,AUDIO_BYTES,PACKET_BYTES
from locate_video import locate

class HQTests(unittest.TestCase):
    def test_payload_padding(self):
        with tempfile.TemporaryDirectory() as td:
            p=Path(td);v=p/'v';a=p/'a';out=p/'HQ.AV'
            v.write_bytes(b'\x55\xaa'*(VIDEO_BYTES//2))
            a.write_bytes(b'\x01\x02\x03\x04')
            info=pack(v,a,out);d=out.read_bytes()
            self.assertEqual(info['sectors'],339)
            self.assertEqual(d[:512],make_header(1))
            self.assertEqual(d[512:512+VIDEO_BYTES],v.read_bytes())
            self.assertEqual(d[512+VIDEO_BYTES:516+VIDEO_BYTES],a.read_bytes())
            self.assertEqual(d[-256:],bytes(256))
            self.assertEqual(len(d),512+PACKET_BYTES)
            with self.assertRaises(FileExistsError):pack(v,a,out)

    def test_fat_hq(self):
        with tempfile.TemporaryDirectory() as td:
            p=Path(td)/'disk.img';d=bytearray(8192*512)
            struct.pack_into('<H',d,11,512);d[13]=1
            struct.pack_into('<H',d,14,1);d[16]=1
            struct.pack_into('<H',d,17,16);struct.pack_into('<H',d,19,8192)
            struct.pack_into('<H',d,22,32);d[510:512]=b'\x55\xaa'
            for c in range(2,341):struct.pack_into('<H',d,512+c*2,c+1 if c<340 else 0xffff)
            r=33*512;d[r:r+11]=b'VIDEOHQ AV ';d[r+11]=32
            struct.pack_into('<H',d,r+26,2);struct.pack_into('<I',d,r+28,512+PACKET_BYTES)
            d[34*512:35*512]=make_header(1);p.write_bytes(d)
            result=locate(p,'VIDEOHQ.AV')
            self.assertEqual(result['lba'],34);self.assertEqual(result['sectors'],339)
            d[34*512+8]^=1;p.write_bytes(d)
            with self.assertRaises(ValueError):locate(p,'VIDEOHQ.AV')

if __name__=='__main__':unittest.main()
