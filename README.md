# SwordSwinger

3D hack & slash roguelike izrađen u Godot 4 engineu. Projekt iz kolegija **3D računalna grafika**

Igrač upravlja vikingom koji se bori kroz osam sve težih valova goblina. Nakon svakog očišćenog vala bira jedan od tri nasumična boona (nadogradnje u stilu igre Hades), a na kraju ga čeka bossfight.

> 🎥 Demo video: [YouTube](https://youtu.be/ExxIJjEjUgI)

## Značajke

- 8 valova rastuće težine s bossom na kraju
- 9 boonova kroz tri nordijska boga: Thor (damage), Odin (survival), Loki (mobility/risk)
- Težinski nasumičan izbor boonova po rijetkosti (common/rare/epic/legendary)
- Hram za izbor boona spawna se na mjestu smrti zadnjeg neprijatelja
- Neprijatelji s navigacijom (NavigationAgent3D) i animacijama
- HUD + lebdeće trake zdravlja iznad likova (SubViewport render-to-texture)
- Zvučni sustav s automatskim učitavanjem efekata

## Kontrole

| Tipka | Radnja |
|---|---|
| WASD / strelice | kretanje |
| Lijevi klik / Space | napad mačem |
| Shift | kotrljanje (dodge) |
| E | interakcija s hramom |
| F | pokretanje runa |
| R | restart |

## Pokretanje

1. Instaliraj [Godot 4](https://godotengine.org/download) (razvijano na verziji 4.x)
2. Kloniraj repozitorij
3. U Godotu: **Import** → odaberi `sword-swinger/project.godot`
4. Pokreni s **F5**, zatim **F** u igri za start runa

## Arhitektura

Projekt počiva na tri principa:

- **Sadržaj su podaci, a ne kod** — boonovi i valovi su Godot Resource datoteke (`.tres`) koje se uređuju kroz Inspector. Novi boon ili val dodaje se bez pisanja koda.
- **Globalno stanje u autoload singletonima** — `PlayerStats`, `BoonManager`, `WaveManager` i `SoundManager` preživljavaju promjene scena i dostupni su iz svih skripti.
- **Komunikacija signalima** — sustavi ne provjeravaju stanje drugih svaki frame, nego reagiraju na događaje (npr. neprijatelj emitira `died`, WaveManager broji preostale žive).

## Struktura projekta

```
sword-swinger/
├── project.godot
├── groundlevel.tscn        # glavna scena (arena)
├── player_model.gd/.tscn   # igrač: kretanje, napad, dodge
├── scripts/
│   ├── player_stats.gd     # autoload: zdravlje, brzina, multiplikatori
│   ├── boon_effect.gd      # shema boona (Resource)
│   ├── boon_manager.gd     # autoload: učitavanje + weighted izbor
│   ├── boon_shrine.gd      # hram u svijetu (Area3D)
│   ├── boon_choice_ui.gd   # sučelje izbora (3 kartice)
│   ├── wave_definition.gd  # shema vala (Resource)
│   ├── wave_manager.gd     # autoload: orkestracija valova
│   ├── enemy.gd            # neprijatelj: navigacija, napad, smrt
│   ├── game_hud.gd         # HUD (HP, brojač valova, banneri)
│   ├── hp_bar_3d.gd        # lebdeća traka zdravlja (SubViewport)
│   ├── sound_manager.gd    # autoload: zvučni efekti
│   └── level_controller.gd # F/R kontrole
├── scenes/
│   ├── boon_shrine.tscn
│   ├── enemy.tscn
│   ├── enemy_boss.tscn
│   └── hp_bar_3d.tscn
├── resources/
│   ├── boons/              # 9 boonova (.tres)
│   └── waves/              # 8 valova (.tres)
└── audio/sfx/              # zvučni efekti
```

## Autori

Projekt su izradili studenti MATHOS-a:

- **Marin Pontoni** — kretanje i animacije lika, dizajn mape, neprijatelj s navigacijom, sustav borbe
- **Tibor Milković** — sustav boonova, sustav valova, boss, HUD i trake zdravlja, zvučni sustav

## Zasluge

- 3D modeli likova: preuzeti gotovi
- Zvučni efekti: [Kenney.nl](https://kenney.nl/assets), [freesound.org](https://freesound.org)
- Dizajnerska inspiracija: *Hades* (Supergiant Games, 2020)
