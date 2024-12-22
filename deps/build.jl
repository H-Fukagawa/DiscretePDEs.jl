using Pkg

##
# Gmshの設定
##
function find_gmshjl()
    try
        # /usr/local/ 直下を検索し、最初に見つかった gmsh.jl のパスを取得
        path = read(pipeline(`find /usr/local/ -name "gmsh.jl"`, `head -n 1`), String)
        return path[1:end-1]
    catch
        return ""
    end
end


##
# Python / Conda の設定
##
function find_conda()
    try
        # システムにある conda のパスを which で取得
        path = read(`which conda`, String)
        return path[1:end-1]
    catch
        try
            # もし which conda で見つからない場合は、ホームディレクトリにある miniconda3/bin/conda を探す
            path = joinpath(homedir(), "miniconda3", "bin", "conda")
            run(`test -f $path`)  # 存在確認
            return path
        catch
            return ""
        end
    end
end

function find_python(conda::String)
    try
        # DiscretePDEs という名前の conda 環境を検索し、そこからパスを取得
        path = read(pipeline(`$conda env list`, `grep DiscretePDEs`, `awk '{print $2}'`), String)
        return joinpath(path[1:end-1], "bin", "python")
    catch
        return ""
    end
end

conda = find_conda()
if conda == ""
    # conda が見つからなければ、miniconda をインストール
    install_conda_sh = joinpath(@__DIR__, "install_conda.sh")
    run(`bash $install_conda_sh`)

    conda = find_conda()
    @assert conda != "" "conda が見つかりません。インストールに失敗した可能性があります。"
end

py_path = find_python(conda)
if py_path == ""
    # DiscretePDEs という環境が見つからなければ、新規に conda_env.yml から環境を作成
    conda_env_yml = joinpath(@__DIR__, "conda_env.yml")
    run(`$conda env create -f $conda_env_yml`)

    py_path = find_python(conda)
    @assert py_path != "" "Python 環境が見つかりません。conda_env.yml の環境作成に失敗した可能性があります。"
end

println("Python path: $py_path")


##
# PyCall のビルド
##
Pkg.build("PyCall")

println("ビルド完了: PyCall および gmsh のセットアップが完了しました。")
