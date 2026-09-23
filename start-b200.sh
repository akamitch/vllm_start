#!/bin/bash
set -e

export HF_HOME=/workspace/hf
export HF_HUB_ENABLE_HF_TRANSFER=1
export UV_CACHE_DIR=/workspace/uv-cache

# кеши на /workspace/ переставить
mkdir -p /root/.cache /workspace/cache
for d in /root/.cache/flashinfer /root/.cache/vllm /root/.triton; do
  name=$(basename $d)
  mkdir -p /workspace/cache/$name
  [ -e "$d" ] && [ ! -L "$d" ] && rm -rf "$d"
  ln -sfn /workspace/cache/$name "$d"
done

# Ставим vLLM, если venv нет или установка не завершилась
if [ ! -x /opt/venv/bin/vllm ]; then
  pip install -q uv
  rm -rf /opt/venv
  uv venv /opt/venv --python 3.12
  uv pip install --python /opt/venv/bin/python -U vllm hf_transfer --torch-backend=auto
fi

source /opt/venv/bin/activate
echo "vLLM version: $(vllm --version)"

vllm serve Qwen/Qwen3.5-122B-A10B-FP8 \
  --host 127.0.0.1 --port 8000 \
  --max-model-len 262144 \
  --max-num-seqs 16 \
  --enable-auto-tool-choice \
  --gpu-memory-utilization 0.95 \
  --language-model-only \
  --reasoning-parser qwen3 \
  --enable-prefix-caching