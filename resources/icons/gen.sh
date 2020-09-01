#!/bin/bash
# Run as ./resources/icons/gen.sh !

OUTPUT=src/opengl/imgui/icons/data.rs

cd resources/icons

cat << EOF > icons.rs
// SVG icons
// This file is automatically generated! See icons/gen.sh !
pub type SvgImageData = (u32, u32, Vec<u8>);

use nsvg;

fn parse(name: &str, str: &'static str) -> SvgImageData {
    nsvg::parse_str(str, nsvg::Units::Pixel, 96.).expect(&format!("Failed to parse SVG {}", name))
        .rasterize_to_raw_rgba(1.).expect(&format!("Failed to rasterize {}", name))
}

EOF

for f in *.svg; do
    ICON_NAME=${f%.svg}
    echo "const ${ICON_NAME^^}_ICON: &str = include_str!(concat!(env!(\"PWD\"), \"/\", \"resources/icons/$f\"));" >> icons.rs
    printf "lazy_static! {\n    pub static ref ${ICON_NAME^^}_ICON_IMAGE: SvgImageData = parse(stringify!($ICON_NAME), ${ICON_NAME^^}_ICON);\n}\n\n" >> icons.rs
done

cd ../..
mv resources/icons/icons.rs "$OUTPUT"
cargo fmt