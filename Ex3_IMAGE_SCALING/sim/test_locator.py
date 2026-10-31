"""Synthetic images only; never touches a physical disk."""
import importlib.util
import struct
import tempfile
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "locator", Path(__file__).resolve().parents[1] / "tools/find_bmp_lba.py")
locator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(locator)


class LocatorTest(unittest.TestCase):
    def image(self, fragmented=False, invalid=False, partition=False):
        base = 2048 if partition else 0
        data = bytearray((base + 2000) * 512)
        def put16(off, val):
            struct.pack_into("<H", data, off, val)
        def put32(off, val):
            struct.pack_into("<I", data, off, val)
        if partition:
            data[510:512] = bytes([85, 170])
            data[450] = 12
            put32(454, base)
        b = base * 512
        data[b + 510:b + 512] = bytes([85, 170])
        # Synthetic FAT16 volume: fixed root directory makes the test small.
        put16(b + 11, 512)
        data[b + 13] = 8
        put16(b + 14, 1)
        data[b + 16] = 1
        put16(b + 17, 512)
        put16(b + 22, 4)
        put32(b + 44, 2)
        fat = (base + 1) * 512
        put16(fat + 6, 0xFFFF)
        for c in range(3, 228):
            put16(fat + c * 2, c + 1)
        put16(fat + 228 * 2, 0xFFFF)
        if fragmented:
            put16(fat + 3 * 2, 9)
        root = (base + 5) * 512
        data[root:root + 11] = b"IMAGE   BMP"
        put16(root + 26, 3)
        put32(root + 28, 921654)
        hdr = (base + 45) * 512
        data[hdr:hdr + 2] = b"BM"
        for off, val in [(2,921654),(10,54),(14,40),(18,640),(22,480)]:
            put32(hdr + off, val)
        put16(hdr + 26, 1)
        put16(hdr + 28, 32 if invalid else 24)
        return data, base + 45

    def test_cases(self):
        with tempfile.TemporaryDirectory() as folder:
            file = Path(folder) / "card.img"
            for partition in (False, True):
                for fragmented, invalid in ((False,False),(True,False),(False,True)):
                    data, expected = self.image(fragmented, invalid, partition)
                    file.write_bytes(data)
                    if fragmented or invalid:
                        with self.assertRaises(ValueError):
                            locator.locate(file)
                    else:
                        self.assertEqual(locator.locate(file), expected)

    def test_numbered_filename(self):
        with tempfile.TemporaryDirectory() as folder:
            file = Path(folder) / 'card.img'
            data, expected = self.image()
            data[5 * 512:5 * 512 + 11] = b'IMAGE2  BMP'
            file.write_bytes(data)
            self.assertEqual(locator.locate(file, filename='IMAGE2.BMP'), expected)
            with self.assertRaises(ValueError):
                locator.locate(file, filename='IMAGE0.BMP')


if __name__ == "__main__":
    unittest.main()
