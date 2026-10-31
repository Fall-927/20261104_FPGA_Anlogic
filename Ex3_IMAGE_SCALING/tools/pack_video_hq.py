"""AV10 v2: 320x240 RGB565LE / 10 fps / 48kHz stereo S16LE.
One header sector; each packet is video(153600), PCM(19200), zero pad(256).
The pad is NOT written into SDRAM. Outputs are exclusive-create, never overwrite.
"""
import argparse
import struct
import json
from pathlib import Path

VIDEO_BYTES=153600
AUDIO_BYTES=19200
PACKET_BYTES=173056
SECTORS=338

def make_header(frames):
    if not 1<=frames<=24818: raise ValueError('Frame count outside supported range')
    h=bytearray(512)
    struct.pack_into('<4sIHHHHIIII',h,0,b'AV10',2,320,240,10,2,48000,frames,VIDEO_BYTES,AUDIO_BYTES)
    return h

def pack(video,audio,output):
    video,audio,output=map(Path,(video,audio,output))
    if output.resolve() in (video.resolve(),audio.resolve()): raise ValueError('Output is an input')
    n,tail=divmod(video.stat().st_size,VIDEO_BYTES)
    if tail: raise ValueError('Incomplete RGB565 frame')
    if audio.stat().st_size%4: raise ValueError('Incomplete stereo PCM sample')
    h=make_header(n)
    with video.open('rb') as vf,audio.open('rb') as af,output.open('xb') as out:
        out.write(h)
        for _ in range(n):
            picture=vf.read(VIDEO_BYTES)
            if len(picture)!=VIDEO_BYTES: raise ValueError('Video changed while packing')
            out.write(picture)
            out.write(af.read(AUDIO_BYTES).ljust(AUDIO_BYTES,b'\0'))
            out.write(bytes(512*SECTORS-VIDEO_BYTES-AUDIO_BYTES))
    return dict(file=str(output),frames=n,seconds=n/10,sectors=1+n*SECTORS,bytes=output.stat().st_size)

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--video',required=True);p.add_argument('--audio',required=True)
    p.add_argument('--output',required=True)
    a=p.parse_args();print(json.dumps(pack(a.video,a.audio,a.output),indent=2))
