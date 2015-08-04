#smoke tests
luajit -lpaths     -e "print('paths loaded succesfully')"
luajit -ltorch     -e "print('torch loaded succesfully')"
luajit -lenv       -e "print('env loaded succesfully')"
luajit -ltrepl     -e "print('trepl loaded succesfully')"
luajit -ldok       -e "print('dok loaded succesfully')"
luajit -limage     -e "print('image loaded succesfully')"
luajit -lsundown   -e "print('sundown loaded succesfully')"
luajit -lcwrap     -e "print('cwrap loaded succesfully')"
luajit -lgnuplot   -e "print('gnuplot loaded succesfully')"
luajit -loptim     -e "print('optim loaded succesfully')"
luajit -lsys       -e "print('sys loaded succesfully')"
luajit -lxlua      -e "print('xlua loaded succesfully')"
luajit -largcheck  -e "print('argcheck loaded succesfully')"
luajit -laudio     -e "print('audio loaded succesfully')"
luajit -lfftw3     -e "print('fftw3 loaded succesfully')"
luajit -lgraph     -e "print('graph loaded succesfully')"
luajit -lnn        -e "print('nn loaded succesfully')"
luajit -lnngraph   -e "print('nngraph loaded succesfully')"
luajit -lnnx       -e "print('nnx loaded succesfully')"
luajit -lgraphicsmagick -e "print('graphicsmagick loaded succesfully')"
luajit -lsdl2      -e "print('sdl2 loaded succesfully')"
luajit -lsignal    -e "print('signal loaded succesfully')"
luajit -lthreads   -e "print('threads loaded succesfully')"

th -ltorch -e "torch.test()"
th -lnn    -e "nn.test()"


# CUDA tests
path_to_nvcc=$(which nvcc)
path_to_nvidiasmi=$(which nvidia-smi)

if [ -x "$path_to_nvcc" ] || [ -x "$path_to_nvidiasmi" ]
then
    luajit -lcutorch -e "print('cutorch loaded succesfully')"
    luajit -lcunn -e "print('cunn loaded succesfully')"
    luajit -lcudnn -e "print('cudnn loaded succesfully')"
    th -lcutorch -e "cutorch.test()"
    th -lcunn -e "nn.testcuda()"
fi
