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
# Example: netmask 24 => 255.255.255.0
{
    local mask=$((0xffffffff << (32 - $1))); shift
    intToip $mask
}


broadcast()
# Example: broadcast 192.0.2.0 24 => 192.0.2.255
{
    local addr=$(ipToint $1); shift
    local mask=$((0xffffffff << (32 -$1))); shift
    intToip $((addr | ~mask))
}

network()
# Example: network 192.0.2.0 24 => 192.0.2.0
{
    local addr=$(ipToint $1); shift
    local mask=$((0xffffffff << (32 -$1))); shift
    intToip $((addr & mask))
}


exit

#Calcular wildcard
IFS=. read -r m1 m2 m3 m4 <<< $mask
wildcard=`printf "%d.%d.%d.%d\n" "$((255 - m1))" "$((255 - m2))" "$((255 - m3))" "$((255 - m4))"`
echo $wildcard

IFS=./ read -r i1 i2 i3 i4 mask<<< $red
# mask=27 1 y (32-27) 0
mask="1"*27+"0"*$((32-27))
echo $mask
IFS=. read -r m1 m2 m3 m4 <<< $mask
printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))" #Al hacer un & nos quedamos con los binarios que coincidan

