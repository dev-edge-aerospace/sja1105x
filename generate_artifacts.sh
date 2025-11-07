# Compile time configuration
# Some platform dependent parameters need to be configured at compile time. These parameters can be found in the Makefile:
#        - NUMBER_SWITCHES: The number of switches attached to the system
#        - SPI_FREQ: Frequency at which the SPI Bus operates
#        - SPI_SWAP: If given a nonzero value, the upper 16bit of a 32bit word are swapped with the lower 16bit
#        - SPI_BPW: bits_per_word setting of the SPI Controller that is used
#        - SPI_BPW_MSG: bits_per_word setting for an individual message, in general this should be equal to SPI_BPW
#        - NR_CFG_BLOCKS: number of words that are sent at once in a single SPI transmission

# Compiles new module
## Remove old modules generated
PROJECT_DIRECTORY="/home/forlinx/work/sja1105x"
rm ${PROJECT_DIRECTORY}/sja1105pqrs.ko

## Compiles new module
echo "## Compiling new sja1105 module with the following parameters"
SPI_SWAP=1 NUMBER_SWITCHES=1 SPI_BPW=16 SPI_BPW_MSG=16 make ARCH=arm64 \
     CROSS_COMPILE=aarch64-linux-gnu- \
     KERNELDIR=/home/forlinx/work/OK10xx-linux-fs/flexbuild/build/linux/linux/arm64/output  \
     EXTRA_CFLAGS="-Wno-error=implicit-function-declaration \
                   -I$(pwd)/platform_independent/inc \
                   -I$(pwd)/platform_independent/inc/low_level_driver \
                   -I$(pwd)/platform_integration/inc/ \
                   -I$(pwd)/app/inc/ \
                   -I$(pwd)/ \
                   -I$(pwd)/switchdev/inc/ \
                   -D SJA1105P_N_SWITCHES=1 \
                   -D SPI_FREQUENCY=12000000 \
                   -D SPI_SWITCH_WORDS=1 \
                   -D SPI_BITS_PER_WORD=16 \
                   -D SPI_BITS_PER_WORD_MSG=16 \
                   -D SPI_CFG_BLOCKS=1" \
     all > generated_artifacts/module_compilation_output.txt

echo "-> sja1105pqrs.ko generated successfully, with the following parameters"
echo "-----------------------------------------------------------------------"
cat generated_artifacts/module_compilation_output.txt | tail -7
echo "-----------------------------------------------------------------------"
## Moves module compiled to the artifact folder
cp sja1105pqrs.ko generated_artifacts/

# Generate sja1105 configuration binaries
## Generates Binaries
echo "## Generating sja1105 configuration binaries..."
cd tools/firmware_generation/sample_generation_scripts/
PYTHONPATH=.. python simplePQRS.py > ${PROJECT_DIRECTORY}/generated_artifacts/binaries_generation_output.txt
echo "-> binaries generated successfully"

## Moves binaries generated to the artifact folder
cp sja1105p_big_endian_cfg.bin ${PROJECT_DIRECTORY}/generated_artifacts/
cp sja1105p_little_endian_cfg.bin ${PROJECT_DIRECTORY}/generated_artifacts/
echo "-----------------------------------------------------------------------"
echo "Obs: files generated are on generated_artifacts/"
