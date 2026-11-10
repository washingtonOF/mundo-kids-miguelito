"""Gera ícones web a partir do avatar atual, preservando transparência."""
from pathlib import Path
from PIL import Image

source = Path("Menino feliz com tablet azul.png")
if not source.exists():
    raise SystemExit("Avatar atual não encontrado.")
image = Image.open(source).convert("RGBA")
# Respeita o canal alpha original do avatar. Não remove cores do personagem.
bbox = image.getchannel("A").getbbox()
if bbox is None:
    raise SystemExit("Avatar sem pixels visíveis.")
image = image.crop(bbox)
def icon(size):
    margin = max(2, round(size * .06))
    result = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    avatar = image.copy()
    avatar.thumbnail((size - 2 * margin, size - 2 * margin), Image.Resampling.LANCZOS)
    result.alpha_composite(avatar, ((size - avatar.width)//2, (size - avatar.height)//2))
    return result

icon(64).save("web/favicon.png")
for size in (192, 512):
    icon(size).save(f"web/icons/Icon-{size}.png")
    icon(size).save(f"web/icons/Icon-maskable-{size}.png")
print("Favicon e ícones web atualizados a partir do avatar.")
