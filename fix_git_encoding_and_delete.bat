@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ====================================
echo   修复Git并删除文件
echo ====================================
echo.

echo [1/6] 设置Git使用UTF-8编码...
git config --global core.quotepath false
git config --global gui.encoding utf-8
git config --global i18n.commit.encoding utf-8
git config --global i18n.logoutputencoding utf-8
echo ✓ Git编码配置完成

echo.
echo [2/6] 检查代理配置...
echo 当前 HTTP 代理: %HTTP_PROXY%
echo 当前 HTTPS 代理: %HTTPS_PROXY%
echo.
set /p use_proxy="需要配置代理吗？(输入端口号如7890，直接回车跳过): "
if not "!use_proxy!"=="" (
    git config --global http.proxy http://127.0.0.1:!use_proxy!
    git config --global https.proxy http://127.0.0.1:!use_proxy!
    echo ✓ 已设置代理为 http://127.0.0.1:!use_proxy!
) else (
    echo ℹ️  跳过代理配置
)

echo.
echo [3/6] 查看当前状态...
git status
echo.

echo [4/6] 添加所有删除操作到暂存区...
git add -A
echo ✓ 已暂存所有更改（包括删除的文件）
echo.

echo [5/6] 查看即将提交的内容...
git status
echo.

echo [6/6] 提交更改...
set /p commit_msg="请输入提交信息（直接回车使用默认信息）: "
if "!commit_msg!"=="" (
    git commit -m "chore: 清理不需要的文件" -m "- 删除临时文件和重复文件" -m "- 优化项目结构"
) else (
    git commit -m "!commit_msg!"
)
echo ✓ 提交完成

echo.
echo [推送] 准备推送到GitHub...
echo.
echo 当前分支状态：
git status
echo.
echo ⚠️  注意：这将推送到远程仓库
echo.
set /p confirm="确定要推送吗？(输入 y 确认，其他键取消): "
if /i "!confirm!"=="y" (
    echo.
    echo 正在尝试推送...
    git push origin main 2>&1 | find "Everything up-to-date" >nul
    if !errorlevel! equ 0 (
        echo ✓ 推送完成！
        goto :done
    )
    
    git push origin main 2>&1 | find "rejected" >nul
    if !errorlevel! equ 0 (
        echo.
        echo ⚠️  普通推送失败，需要强制推送
        echo.
        set /p force_confirm="是否使用 --force 强制推送？(输入 y 确认): "
        if /i "!force_confirm!"=="y" (
            echo.
            echo 正在强制推送...
            git push origin main --force
            if !errorlevel! equ 0 (
                echo ✓ 强制推送完成！
            ) else (
                echo ❌ 推送失败，请检查网络连接
                echo.
                echo 💡 如果使用代理，请确保代理正在运行
                echo 💡 可以尝试手动运行：
                echo    git config --global http.proxy http://127.0.0.1:7890
                echo    git push origin main --force
            )
        ) else (
            echo ℹ️  已取消强制推送
        )
    ) else (
        echo 正在推送...
        git push origin main
        if !errorlevel! equ 0 (
            echo ✓ 推送完成！
        ) else (
            echo ❌ 推送失败，请检查网络连接
        )
    )
) else (
    echo ℹ️  已取消推送
    echo.
    echo 💡 如果确认修改无误，可以手动运行：
    echo    git push origin main
    echo 或强制推送：
    echo    git push origin main --force
)

:done
echo.
echo ====================================
echo   完成！
echo ====================================
pause
