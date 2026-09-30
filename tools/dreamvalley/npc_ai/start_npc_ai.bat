@echo off
rem Starts the NPC mind: a local llama.cpp server the game talks to on
rem 127.0.0.1:8089. Leave this window open while playing. The game works
rem without it; NPCs just fall back to plain behaviour.
rem
rem It shares the machine with the game, so by default it takes only part of
rem the GPU and part of the CPU, at low priority. Tune these if needed:

rem Model layers on the GPU (0 = CPU only, 28 = whole model). ~130 MB of VRAM per layer.
if not defined NPC_GPU_LAYERS set NPC_GPU_LAYERS=12
rem CPU threads the mind may use. Leave the rest for the game.
if not defined NPC_THREADS set NPC_THREADS=4
rem How many NPCs may think at the same moment.
if not defined NPC_PARALLEL set NPC_PARALLEL=1

setlocal
set ROOT=%~dp0..\..\..
set CACHE=%ROOT%\tools\bootstrap\.cache\npc_ai
set SERVER=%CACHE%\llama-b11284\llama-server.exe
set MODEL=%CACHE%\models\Qwen2.5-7B-Instruct-Q4_K_M.gguf

if not exist "%SERVER%" goto setup
if not exist "%MODEL%" goto setup
goto run

:setup
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
if errorlevel 1 (
	echo Setup failed.
	pause
	exit /b 1
)

:run
echo NPC mind: %NPC_GPU_LAYERS% layers on the GPU, %NPC_THREADS% CPU threads, low priority.
rem /belownormal keeps the game ahead of the mind whenever both want the machine.
start "NPC mind" /belownormal /wait "%SERVER%" -m "%MODEL%" --host 127.0.0.1 --port 8089 -ngl %NPC_GPU_LAYERS% -t %NPC_THREADS% -tb %NPC_THREADS% -c 4096 -np %NPC_PARALLEL%
pause
