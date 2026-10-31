# Řídicí klipy LivePortraitu

`drivergen.py` vyrobí `assets/drivers/<motion>.mp4` podle
`assets/drivers/manifest.json`: Wan přes video-api ze syntetické předlohy
`srcs/w-long.png`, ořez a návrat do neutrálu (poslední snímek = první), `alive`
slepený z dílů. Klipy v repu zatím nejsou; dokud chybí, preset vrací 422.

Běží na GPU, takže přes broker (dávka z tohoto stroje):

```bash
sparkctl exec tsumiki <služby> 180 "drivers" -- \
  python3 tgbot/tools/bench/drivers/drivergen.py --url http://192.168.88.66:8096/v1/video
```

Název služby a projekt: `sparkctl catalog`. `--only blink,smile` přegeneruje
jen některé. Seed se zapíše do manifestu.

Skript metriky nekontroluje. Plán 09 §4 chce driver, který nemrkne, zahodit;
to dělá `run.py live --engines driver --srcs srcs/w-long.png --out out/drivers`
a `score.py out/drivers`: klip se změří jako výstup, nic se nerenderuje.

Vlastní nahrávka je povolená jen lokálně, mimo repo.
