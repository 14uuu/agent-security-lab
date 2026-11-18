#!/usr/bin/env bash
# 完整实验管线：benign 基线 + 攻击 A/B/C 各自叠加防御 none/d1/d12/d123
# 结果写入 results/exp_<timestamp>/，不覆盖既有 results/*.csv
set -u
cd "$(dirname "$0")"
export PYTHONUTF8=1
export PYTHONIOENCODING=utf-8

TS=$(date +%Y%m%d_%H%M%S)
R="results/exp_${TS}"
mkdir -p "$R"
LOG="$R/run.log"
echo "results dir: $R" | tee "$LOG"

run() {
  echo "" | tee -a "$LOG"
  echo ">>> python experiments/run_experiment.py $*" | tee -a "$LOG"
  python experiments/run_experiment.py "$@" 2>&1 | tee -a "$LOG"
}

# 基线（无攻击，应全部 FAIL）
run --suite benign --runs 1 --out "$R/benign.csv"
run --suite benign --runs 1 --defense d2 --out "$R/benign_d2.csv"

# 攻击 A：MCP description 投毒 / 内存注入
run --suite attack_a --runs 3 --out "$R/a.csv"
run --suite attack_a --runs 3 --defense d1 --out "$R/a_d1.csv"
run --suite attack_a --runs 3 --defense d1,d2 --out "$R/a_d12.csv"
run --suite attack_a --runs 3 --defense d1,d2,d3 --out "$R/a_d123.csv"

# 攻击 B：工具返回数据中的间接提示注入
run --suite attack_b --runs 3 --out "$R/b.csv"
run --suite attack_b --runs 3 --defense d1 --out "$R/b_d1.csv"
run --suite attack_b --runs 3 --defense d1,d2 --out "$R/b_d12.csv"
run --suite attack_b --runs 3 --defense d1,d2,d3 --out "$R/b_d123.csv"

# 攻击 C：多来源组合诱导
run --suite attack_c --runs 3 --out "$R/c.csv"
run --suite attack_c --runs 3 --defense d1 --out "$R/c_d1.csv"
run --suite attack_c --runs 3 --defense d1,d2 --out "$R/c_d12.csv"
run --suite attack_c --runs 3 --defense d1,d2,d3 --out "$R/c_d123.csv"

echo "" | tee -a "$LOG"
echo "ALL DONE -> $R" | tee -a "$LOG"
