#!/bin/sh
set -e

if [ -z "$1" ]; then
    echo "Ошибка: Не указан исходный файл." >&2
    exit 1
fi

SRC_FILE="$1"

if [ ! -f "$SRC_FILE" ]; then
    echo "Ошибка: Файл '$SRC_FILE' не найден." >&2
    exit 1
fi

SRC_DIR=$(cd "$(dirname "$SRC_FILE")" && pwd)
SRC_BASE=$(basename "$SRC_FILE")

OUT_NAME=$(grep -o '[Oo]utput:[[:space:]]*[^[:space:]]*' "$SRC_FILE" | head -n 1 | sed 's/[Oo]utput:[[:space:]]*//')

if [ -z "$OUT_NAME" ]; then
    echo "Ошибка: В файле не найдена метка 'Output: имя_файла'." >&2
    exit 2
fi

BUILD_DIR=$(mktemp -d -t build_tmp.XXXXXX)

cleanup() {
    rm -rf "$BUILD_DIR"
}
trap cleanup EXIT INT TERM HUP

cp "$SRC_FILE" "$BUILD_DIR/"

cd "$BUILD_DIR"

case "$SRC_BASE" in
    *.c)
        gcc -O2 "$SRC_BASE" -o "$OUT_NAME" || { echo "Ошибка: Сбой компиляции C." >&2; exit 3; }
        ;;
    *.cpp|*.cc|*.cxx)
        g++ -O2 "$SRC_BASE" -o "$OUT_NAME" || { echo "Ошибка: Сбой компиляции C++." >&2; exit 3; }
        ;;
    *.tex)
        pdflatex -interaction=nonstopmode "$SRC_BASE" >/dev/null 2>&1 || { echo "Ошибка: Сбой сборки TeX." >&2; exit 3; }
        TEX_OUT="${SRC_BASE%.tex}.pdf"
        if [ -f "$TEX_OUT" ] && [ "$TEX_OUT" != "$OUT_NAME" ]; then
            mv "$TEX_OUT" "$OUT_NAME"
        fi
        ;;
    *)
        echo "Ошибка: Неизвестное расширение файла ($SRC_BASE)." >&2
        exit 4
        ;;
esac

if [ ! -f "$OUT_NAME" ]; then
    echo "Ошибка: Конечный файл не был создан в процессе сборки." >&2
    exit 3
fi

mv "$OUT_NAME" "$SRC_DIR/"

echo "Сборка успешно завершена: $SRC_DIR/$OUT_NAME"

