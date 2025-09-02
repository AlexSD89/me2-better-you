#!/bin/bash

# 安全的JSON读取函数 - 可以被其他Hook引用
safe_jq() {
    local file="$1"
    local query="$2"
    local default="$3"
    
    if [[ -f "$file" ]]; then
        jq -r "$query" "$file" 2>/dev/null | tr -d '\n\r' | sed 's/[[:cntrl:]]//g' || echo "$default"
    else
        echo "$default"
    fi
}

# 安全的JSON数组读取函数
safe_jq_array() {
    local file="$1"
    local query="$2"
    local default="$3"
    
    if [[ -f "$file" ]]; then
        jq -r "$query[]?" "$file" 2>/dev/null | tr -d '\n\r' | sed 's/[[:cntrl:]]//g' | tr '\n' ' ' || echo "$default"
    else
        echo "$default"
    fi
}