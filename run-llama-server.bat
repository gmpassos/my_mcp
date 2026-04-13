
set CUDA_VISIBLE_DEVICES=0

:: llama-server.exe -m "models\gemma-4-E2B-it-Q4_K_M.gguf" -ngl 60 --ctx-size 4096 --temp 0.7 --top-p 0.9 --repeat-penalty 1.1 --host 127.0.0.1 --port 8080

llama-server.exe -m "models\gemma-4-E2B-it-Q4_K_M.gguf" -ngl 999 -b 1024 --ctx-size 20000 --temp 0.7 --top-p 0.9 --repeat-penalty 1.1 --host 127.0.0.1 --port 8080 --webui-mcp-proxy --webui-config-file webui-config.json

