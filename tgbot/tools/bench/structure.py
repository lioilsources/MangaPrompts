"""Třídy struktury vlasů — to jediné, na co se vyplatí ptát CLIPu.

Proč vůbec: `recognised` se CLIPu ptalo „je tohle `lob`?" v sadě 31–34 nálepek
jedné skupiny. Změřeno 16. 9. 2026 (`metric_check.py`): tři z šesti **reálných
předloh** takhle CLIP nepozná a na všech třech ženských vyhrává `face-framing`
bez ohledu na obsah. Nepomohla ani hrubší sada tříd s délkou — `lob` i dlouhé
vlasy hlásí jako `bob`. Metrika tedy měřila rozlišitelnost nálepek, ne věrnost
účesu, a rozhodovala o katalozích appek.

Délku a ofinu přitom bench měří geometricky a správně (`below` → `length_ok`,
`cover` → `bangs_ok`). CLIPu zbývá to, co geometrie nevidí: jak jsou vlasy
uspořádané. Na tom funguje — copánky hlásí s jistotou 0,99–1,00.

`loose` je výchozí třída a znamená **„CLIP nemá co dodat"**: u střihu, který
je definovaný jen délkou a ofinou (bob, lob, dlouhé vrstvy), rozhoduje sama
geometrie a `structure_ok` se nepočítá. Radši žádné číslo než číslo, které
měří něco jiného.
"""

# Pozor na podřetězce: "loc" sedí i v "two-block", proto "locs" a "dread".
BRAIDED = ("braid", "cornrow", "twist", "locs", "dread")
CURLY = ("curl", "wave", "afro", "perm", "coil")
CLIPPED = ("buzz", "shaved", "skin-fade", "skin fade")

# Formulace jsou o **uspořádání**, ne o délce: délka je geometrie a CLIP ji
# stejně neumí (lob i dlouhé vlasy hlásí jako bob). Vybrané ze čtyř sad
# zkoušených na předlohách (`metric_check.py --structure`): tahle jediná je
# zařadila správně, ostatní hlásily na blond mikádu „oholenou hlavu".
TEXTS = {
    "braided": "a photo of braided hair, plaits",
    "curly": "a photo of curly wavy hair",
    "updo": "a photo of hair tied up, a bun or ponytail",
    "clipped": "a photo of a buzz cut, shaved head",
    "loose": "a photo of hair hanging down loose and unstyled",
}

#: Třídy, na které se CLIP ptá. `loose` je mezi nimi jako protiváha — bez ní
#: by se „nic z toho" nemělo kam zařadit a volné vlasy by spadly do nejbližší
#: struktury.
CLASSES = tuple(TEXTS)

#: Třídy, kterými se **smí gatovat**. Zbytek už pokrývá geometrie a měřit ho
#: podruhé nespolehlivým nástrojem by jen vracelo šum: `updo` hlídá
#: `updo_below_max`, `clipped` a `loose` délka. Zbývají copánky a kudrny —
#: struktura, kterou `below` ani `cover` nevidí.
GATED = ("braided", "curly")


def structure_class(style: dict) -> str:
    """Třída struktury kandidáta (`candidates/hairstyles.json`)."""
    text = f"{style['id']} {style['label']}".lower()
    if style.get("section") == "Braids" or any(w in text for w in BRAIDED):
        return "braided"
    if style["shape"]["updo"]:
        return "updo"
    if any(w in text for w in CLIPPED):
        return "clipped"
    if any(w in text for w in CURLY):
        return "curly"
    return "loose"


def measurable(style: dict) -> bool:
    """Má u tohohle střihu smysl se CLIPu ptát? Jen u tříd v [GATED]."""
    return structure_class(style) in GATED


def gated_by(style: dict) -> str:
    """Čím je styl prověřený. `nothing` = ničím: délka se nemá změnit, ofina
    žádná a struktura je volné vlasy, takže **žádná metrika nemůže selhat**.
    Takový styl se nesmí označit za „prošel" — neprošel, jen se nedal změřit.
    `face-framing`, `sleek-straight` a `side-undercut` jsou přesně tenhle
    případ; `face-framing` navíc CLIP hlásil skoro na každé ženské fotce, takže
    se ve starém gate tvářil jako nejspolehlivější položka katalogu.
    """
    sh = style["shape"]
    if measurable(style):
        return "structure"
    if sh["updo"] or sh["length"] != "keep":
        return "length"
    if sh["bangs"] != "none":
        return "bangs"
    return "nothing"
