#!/bin/bash

red=192.168.0.0/27
ipToint()
{
    local a b c d
    { IFS=. read a b c d; } <<< $1
    echo $(((((((a << 8) | b) << 8) | c) << 8) | d))  #(((192*2^8+168)2^8)+0*2^8)+0=192*2^24+168*2^16+0*2^8+0
}
intToip()
{
    local ui32=$1; shift
    local ip n
    for n in 1 2 3 4; do
        ip=$((ui32 & 0xff))${ip:+.}$ip
        ui32=$((ui32 >> 8))
    done
    echo $ip
}
netmask()
# Example: netmask 27 => 255.255.255.224
{
    local mask=$((0xffffffff << (32 - $1))); shift
    intToip $mask
}

broadcast()
# Example: broadcast 192.168.0.0 27 => 192.168.0.31
{
    local addr=$(ipToint $1); shift
    local mask=$((0xffffffff << (32 - $1))); shift
    intToip $((addr | ~mask))
}

network()
# Example: network 192.68.11.155 21 => 192.68.8.0
{
    local addr=$(ipToint $1); shift
    local mask=$((0xffffffff << (32 -$1))); shift
    intToip $((addr & mask))
}

# #Get wildcard
# IFS=. read -r m1 m2 m3 m4 <<< $mask
# wildcard=`printf "%d.%d.%d.%d\n" "$((255 - m1))" "$((255 - m2))" "$((255 - m3))" "$((255 - m4))"`
# echo $wildcard

IFS=./ read -r i1 i2 i3 i4 mask<<< $red
if [[ -z $mask ]]; then
    mask=32
fi
broadcast=$(broadcast $i1.$i2.$i3.$i4 $mask)
IFS=. read -r b1 b2 b3 b4 <<< $broadcast
red=$(network $i1.$i2.$i3.$i4 $mask)
netmask=$(netmask $mask)
echo $red $broadcast $netmask
networkIP=()
m=0
networkIP[0]=$red
for ((i = $i1; i <= $b1; i++)); do
    for ((j = $i2; j <= $b2; j++)); do
        for ((k = $i3; k <= $b3; k++)); do
            for ((h = $((i4+1)); h <= $b4; h++)); do
                let m++
                networkIP[$m]=$i.$j.$k.$h # Guardo las IP de la red
            done
        done
    done
done
for ((m = 1; m < $((${#networkIP[@]}-1)); m++)); do
    echo ${networkIP[$m]}
done
