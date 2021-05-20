@echo off
chcp

for /f "tokens=4" %%i in ('chcp') do (
	if %%i==1251 (
		echo Everything's alright
	) else (
		chcp 1251 > nul
		echo Page changed from %%i to 1251
	)
)