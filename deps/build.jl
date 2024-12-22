using Pkg
using DotEnv

env = joinpath(@__DIR__, ".env")

# .env ファイルを追加モードで開き、存在しない場合は作成
open(env, "a") do io
    # 必要な環境変数をここに書き込む
    # 例:
    # println(io, "gmshjl=/usr/local/share/julia/DiscretePDEs/gmsh.jl")
    # println(io, "PYTHON=/Users/hiroki/miniconda3/envs/DiscretePDEs/bin/python")
end  # do ブロックを閉じる

# .env ファイルをロード
DotEnv.load(env)

env_keys = ["gmshjl", "PYTHON"]

# Gmshの設定
find_gmshjl() = try
    path = read(pipeline(`find /usr/local/ -name "gmsh.jl"`, `head -n 1`), String)
    path[1:end-1]
catch
    ""
end

key = env_keys[1]
if !(key in keys(ENV))
    value = find_gmshjl()
    if value == ""
        # Gmshのインストール
        install_gmsh_sh = joinpath(@__DIR__, "install_gmsh.sh")
        run(`bash $install_gmsh_sh`)
        value = find_gmshjl()
        @assert value != ""
    end
    ENV[key] = value
    println("$key=$value")
end

# Pythonの設定
find_conda() = try
    path = read(`which conda`, String)
    path[1:end-1]
catch
    try
        path = joinpath(homedir(), "miniconda3", "bin", "conda")
        run(`test -f $path`) # ファイルの存在を確認
        path
    catch
        ""
    end
end

find_python(conda::String) = try
    path = read(pipeline(`$conda env list`, `grep DiscretePDEs`, `awk '{print $2}'`), String)
    joinpath(path[1:end-1], "bin", "python")
catch
    ""
end

key = env_keys[2]
if !(key in keys(ENV))
    conda = find_conda()
    if conda == ""
        # Condaのインストール
        install_conda_sh = joinpath(@__DIR__, "install_conda.sh")
        run(`bash $install_conda_sh`)
        conda = find_conda()
        @assert conda != ""
    end
    value = find_python(conda)
    if value == ""
        # 仮想環境の作成
        conda_env_yml = joinpath(@__DIR__, "conda_env.yml")
        run(`$conda env create -f $conda_env_yml`)
        value = find_python(conda)
        @assert value != ""
    end
    ENV[key] = value
    println("$key=$value")
end

Pkg.build("PyCall")

# .env ファイルに保存
env_contents = reduce(*, ["$k=$(ENV[k])\n" for k in env_keys])
open(env, "w") do io
    write(io, env_contents)
end  # do ブロックを閉じる
