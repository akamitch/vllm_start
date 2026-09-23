#!/bin/bash
set -e

# Модель можно передать аргументом: bash download.sh Qwen/Qwen3.5-122B-A10B-FP8
MODEL=${1:-Qwen/Qwen3.5-122B-A10B-FP8}

export HF_HOME=/workspace/hf
export HF_HUB_ENABLE_HF_TRANSFER=1

# hf CLI ставим в системный python, чтобы качать веса, не дожидаясь установки vLLM
if ! command -v hf >/dev/null 2>&1; then
  pip install -q -U huggingface_hub hf_transfer
fi

echo "Качаем $MODEL в $HF_HOME"

# При обрыве сети повторяем: hf download докачивает, уже скачанные файлы пропускает
until hf download "$MODEL"; do
  echo "Ошибка скачивания, повтор через 10 сек..."
  sleep 10
done

echo "Готово:"
du -sh "$HF_HOME/hub/models--${MODEL//\//--}"
