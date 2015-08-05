LUA=$(which luajit)
LUA=${LUA:-"lua"}
echo $LUA

#smoke tests
$LUA -lpaths     -e "print('paths loaded succesfully')"
$LUA -ltorch     -e "print('torch loaded succesfully')"
$LUA -lenv       -e "print('env loaded succesfully')"
$LUA -ltrepl     -e "print('trepl loaded succesfully')"
$LUA -ldok       -e "print('dok loaded succesfully')"
$LUA -limage     -e "print('image loaded succesfully')"
$LUA -lcwrap     -e "print('cwrap loaded succesfully')"
$LUA -lgnuplot   -e "print('gnuplot loaded succesfully')"
$LUA -loptim     -e "print('optim loaded succesfully')"
$LUA -lsys       -e "print('sys loaded succesfully')"
$LUA -lxlua      -e "print('x$LUA loaded succesfully')"
$LUA -largcheck  -e "print('argcheck loaded succesfully')"
$LUA -lgraph     -e "print('graph loaded succesfully')"
$LUA -lnn        -e "print('nn loaded succesfully')"
$LUA -lnngraph   -e "print('nngraph loaded succesfully')"
$LUA -lnnx       -e "print('nnx loaded succesfully')"
$LUA -lthreads   -e "print('threads loaded succesfully')"

th -ltorch -e "torch.test()"
th -lnn    -e "nn.test()"

if [ $LUA == 'luajit' ];
then
    $LUA -lsundown   -e "print('sundown loaded succesfully')"
    $LUA -lsignal    -e "print('signal loaded succesfully')"
    $LUA -lgraphicsmagick -e "print('graphicsmagick loaded succesfully')"
    $LUA -lfftw3     -e "print('fftw3 loaded succesfully')"
    $LUA -laudio     -e "print('audio loaded succesfully')"
fi


# CUDA tests
path_to_nvcc=$(which nvcc)
path_to_nvidiasmi=$(which nvidia-smi)

if [ -x "$path_to_nvcc" ] || [ -x "$path_to_nvidiasmi" ]
then
    $LUA -lcutorch -e "print('cutorch loaded succesfully')"
    $LUA -lcunn -e "print('cunn loaded succesfully')"
    if [ $LUA == 'luajit' ];
    then
        $LUA -lcudnn -e "print('cudnn loaded succesfully')"
    fi
    th -lcutorch -e "cutorch.test()"
    th -lcunn -e "nn.testcuda()"
fi
