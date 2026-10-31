"""Pack 160x120 RGB565LE + 48k stereo S16LE into sector-aligned AV15.

No disk/device writes. One 512-byte header, then 100 sectors per frame:
38400 bytes top-down video followed by 12800 bytes (3200 stereo samples).
Video duration is authoritative: audio is padded with silence or truncated.
"""
import argparse
import json
import struct
from pathlib import Path

VIDEO_BYTES = 38400
AUDIO_BYTES = 12800
PACKET_BYTES = VIDEO_BYTES + AUDIO_BYTES


def make_header(frames):
    if not 0 < frames <= 83886:
        raise ValueError('Invalid frame count')
    h = bytearray(512)
    struct.pack_into('<4sIHHHHIIII', h, 0, b'AV15', 1, 160, 120, 15, 2,
                     48000, frames, VIDEO_BYTES, AUDIO_BYTES)
    return h


def validate_header(h):
    if len(h) != 512:
        raise ValueError('Short header')
    values = struct.unpack_from('<4sIHHHHIIII', h)
    if values[:7] != (b'AV15', 1, 160, 120, 15, 2, 48000):
        raise ValueError('Unsupported AV15 format')
    frames = values[7]
    if values[8:] != (VIDEO_BYTES, AUDIO_BYTES) or not frames:
        raise ValueError('Invalid AV15 sizes')
    make_header(frames)
    if any(h[32:]):
        raise ValueError('Reserved header bytes must be zero')
    return frames


def pack(video, audio, output):
    video, audio, output = map(Path, (video, audio, output))
    if output.resolve() in (video.resolve(), audio.resolve()):
        raise ValueError('Output must not overwrite an input')
    size = video.stat().st_size
    if not size or size % VIDEO_BYTES:
        raise ValueError('RGB565 input must contain whole 38400-byte frames')
    if audio.stat().st_size % 4:
        raise ValueError('PCM must contain whole stereo S16LE samples')
    frames = size // VIDEO_BYTES
    header = make_header(frames)
    with video.open('rb') as vf, audio.open('rb') as af, output.open('xb') as out:
        out.write(header)
        for _ in range(frames):
            picture = vf.read(VIDEO_BYTES)
            if len(picture) != VIDEO_BYTES:
                raise ValueError('Input video changed during conversion')
            out.write(picture)
            out.write(af.read(AUDIO_BYTES).ljust(AUDIO_BYTES, b'\0'))
    return {'file': str(output), 'frames': frames, 'duration_seconds': frames / 15,
            'sectors': 1 + frames * 100, 'bytes': output.stat().st_size,
            'audio_source_bytes': audio.stat().st_size,
            'audio_used_bytes': frames * AUDIO_BYTES}


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--video', required=True)
    p.add_argument('--audio', required=True)
    p.add_argument('--output', required=True)
    a = p.parse_args()
    print(json.dumps(pack(a.video, a.audio, a.output), indent=2))
