#!/bin/bash
# Claude Code Python Sandbox Manager
# Integrates with Python execution MCP server for safe code testing

# Set debug mode from environment variable
DEBUG="${CLAUDE_HOOK_DEBUG:-false}"

# Function to log debug messages
debug_log() {
    if [ "$DEBUG" = "true" ]; then
        echo "[DEBUG $(date '+%H:%M:%S')] Python Sandbox: $1" >> .claude/logs/python-sandbox.log
    fi
}

# Function to log info messages
log_info() {
    echo "[INFO $(date '+%H:%M:%S')] Python Sandbox: $1" | tee -a .claude/logs/python-sandbox.log
}

# Function to validate Python code before execution
validate_python_code() {
    local file_path="$1"
    debug_log "Validating Python code: $file_path"
    
    if [ ! -f "$file_path" ]; then
        debug_log "File not found: $file_path"
        return 1
    fi
    
    # Basic syntax check
    if python -m py_compile "$file_path" 2>/dev/null; then
        debug_log "Python syntax validation passed: $file_path"
        return 0
    else
        log_info "Python syntax validation failed: $file_path"
        return 1
    fi
}

# Function to run security scan on Python code
security_scan_python() {
    local file_path="$1"
    debug_log "Running security scan on: $file_path"
    
    # Check for potentially dangerous imports and functions
    local dangerous_patterns=(
        "import os"
        "import subprocess"
        "import shutil"
        "eval("
        "exec("
        "__import__"
        "open.*[\"']w[\"']"
        "remove"
        "rmdir"
        "unlink"
    )
    
    local security_issues=0
    for pattern in "${dangerous_patterns[@]}"; do
        if grep -q "$pattern" "$file_path" 2>/dev/null; then
            log_info "Security concern detected: $pattern in $file_path"
            ((security_issues++))
        fi
    done
    
    if [ $security_issues -eq 0 ]; then
        debug_log "Security scan passed: $file_path"
        return 0
    else
        log_info "Security scan found $security_issues potential issues in $file_path"
        return 1
    fi
}

# Function to run Python code in sandbox
execute_in_sandbox() {
    local file_path="$1"
    local run_tests="${2:-false}"
    
    debug_log "Preparing sandbox execution for: $file_path"
    
    # Validate code first
    if ! validate_python_code "$file_path"; then
        return 1
    fi
    
    # Run security scan
    if ! security_scan_python "$file_path"; then
        log_info "Code failed security scan, sandbox execution blocked"
        return 1
    fi
    
    # Create sandbox execution report
    local execution_report=".claude/logs/sandbox-execution-$(date +%Y%m%d-%H%M%S).json"
    
    cat > "$execution_report" << EOF
{
  "file": "$file_path",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)",
  "validation": "passed",
  "security_scan": "passed",
  "execution_status": "initiated"
}
EOF
    
    log_info "Python code prepared for sandbox execution: $file_path"
    
    # If it's a test file, run with test framework
    if [[ "$file_path" =~ test.*\.py$ ]] || [ "$run_tests" = "true" ]; then
        run_python_tests "$file_path"
    fi
}

# Function to run Python tests
run_python_tests() {
    local file_path="$1"
    debug_log "Running Python tests: $file_path"
    
    # Determine appropriate test runner
    if command -v pytest &> /dev/null; then
        log_info "Running tests with pytest: $file_path"
        pytest "$file_path" --tb=short -v 2>&1 | tee -a .claude/logs/test-results.log
    elif python -m unittest discover -s "$(dirname "$file_path")" -p "$(basename "$file_path")" &> /dev/null; then
        log_info "Running tests with unittest: $file_path"
        python -m unittest discover -s "$(dirname "$file_path")" -p "$(basename "$file_path")" 2>&1 | tee -a .claude/logs/test-results.log
    else
        log_info "Running file directly: $file_path"
        python "$file_path" 2>&1 | tee -a .claude/logs/execution-results.log
    fi
}

# Function to analyze Python code for quality metrics
analyze_code_quality() {
    local file_path="$1"
    debug_log "Analyzing code quality: $file_path"
    
    local quality_report=".claude/logs/quality-analysis-$(basename "$file_path" .py).json"
    
    # Initialize quality metrics
    local lines_of_code=$(wc -l < "$file_path")
    local functions_count=$(grep -c "^def " "$file_path" || echo "0")
    local classes_count=$(grep -c "^class " "$file_path" || echo "0")
    local imports_count=$(grep -c "^import\|^from.*import" "$file_path" || echo "0")
    
    # Create quality report
    cat > "$quality_report" << EOF
{
  "file": "$file_path",
  "metrics": {
    "lines_of_code": $lines_of_code,
    "functions": $functions_count,
    "classes": $classes_count,
    "imports": $imports_count
  },
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)"
}
EOF
    
    debug_log "Quality analysis completed: $file_path"
}

# Function to handle different file operations
handle_file_operation() {
    local operation="$1"
    local file_path="$2"
    
    # Only process Python files
    if [[ "$file_path" =~ \.py$ ]]; then
        case "$operation" in
            "Edit"|"MultiEdit"|"Write")
                log_info "Python file modified: $file_path"
                analyze_code_quality "$file_path"
                execute_in_sandbox "$file_path"
                ;;
        esac
    fi
}

# Function to setup Python development environment
setup_python_environment() {
    debug_log "Setting up Python development environment"
    
    # Check if virtual environment should be created
    if [ ! -d "venv" ] && [ -f "requirements.txt" ]; then
        log_info "Creating Python virtual environment"
        python -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
    fi
    
    # Install common development packages
    local dev_packages=("pytest" "black" "flake8" "mypy")
    for package in "${dev_packages[@]}"; do
        if ! pip show "$package" &> /dev/null; then
            debug_log "Installing $package"
            pip install "$package" &> /dev/null
        fi
    done
}

# Main execution
main() {
    # Create logs directory if it doesn't exist
    mkdir -p .claude/logs
    
    # Setup Python environment
    setup_python_environment
    
    # Handle file operation if provided
    if [ $# -ge 2 ]; then
        handle_file_operation "$1" "$2"
    fi
    
    debug_log "Python sandbox manager completed"
}

# Execute main function with all arguments
main "$@"