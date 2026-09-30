# Fetches the NPC mind's model server and model into the repo's own cache.
# Everything lands in tools/bootstrap/.cache/npc_ai (git-ignored). Run it once;
# it skips anything already present. start_npc_ai.bat calls it for you.

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$Build = "b11284"
$Cuda = "12.4"
$ModelUrl = "https://huggingface.co/bartowski/Qwen2.5-7B-Instruct-GGUF/resolve/main/Qwen2.5-7B-Instruct-Q4_K_M.gguf"
$ModelFile = "Qwen2.5-7B-Instruct-Q4_K_M.gguf"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..\..\..")
$Cache = Join-Path $Root "tools\bootstrap\.cache\npc_ai"
$ServerDir = Join-Path $Cache "llama-$Build"
$ModelDir = Join-Path $Cache "models"
New-Item -ItemType Directory -Force $Cache, $ModelDir | Out-Null

function Fetch-Zip($url, $dest) {
	$zip = Join-Path $Cache ([IO.Path]::GetFileName($url))
	if (-not (Test-Path $zip)) {
		Write-Host "Downloading $url"
		Invoke-WebRequest -Uri $url -OutFile "$zip.part"
		Move-Item "$zip.part" $zip
	}
	Expand-Archive -Force $zip $dest
}

if (-not (Test-Path (Join-Path $ServerDir "llama-server.exe"))) {
	$base = "https://github.com/ggml-org/llama.cpp/releases/download/$Build"
	Fetch-Zip "$base/llama-$Build-bin-win-cuda-$Cuda-x64.zip" $ServerDir
	Fetch-Zip "$base/cudart-llama-bin-win-cuda-$Cuda-x64.zip" $ServerDir
}

$Model = Join-Path $ModelDir $ModelFile
if (-not (Test-Path $Model)) {
	Write-Host "Downloading the model (about 4.7 GB, once)..."
	Invoke-WebRequest -Uri $ModelUrl -OutFile "$Model.part"
	Move-Item "$Model.part" $Model
}

Write-Host "NPC mind ready: $ServerDir\llama-server.exe with $ModelFile"
