
:: set CUDA_VISIBLE_DEVICES=0

:: llama-server.exe -m "models\gemma-4-E2B-it-Q4_K_M.gguf" -ngl 999 -b 1024 --ctx-size 128000 --temp 0.7 --top-p 0.9 --repeat-penalty 1.1 --host 127.0.0.1 --port 8080 --webui-mcp-proxy --webui-config-file webui-config.json

set CUDA_VISIBLE_DEVICES=0,1

llama-server.exe -m "models\gemma-4-E4B-it-Q4_K_M.gguf" -ngl 999 -b 1024 --ctx-size 128000 --temp 0.7 --top-p 0.9 --repeat-penalty 1.1 --host 127.0.0.1 --port 8080 --parallel 2 --tensor-split 1,0 --webui-mcp-proxy --webui-config-file webui-config.json

