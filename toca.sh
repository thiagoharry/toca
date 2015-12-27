#!/bin/bash

#####################
# VARIÁVEIS GLOBAIS #
#####################

# Programa tcador de áudio
TOCADOR="mplayer -noconsolecontrols"
# Extensão de arquivos reconhecidas como músicas
FORMATOS=".ogg .mp3 .mp4 .ogv"
# Local onde buscar músicas
DIR_MUSICA=~/acervos/musicas/

###########
# FUNÇÕES #
###########

# Argumento: Caminho para arquivo
# Saída: Seu arquivo de legenda esperado
function legenda(){
    nome=${1%.*}
    echo $(dirname $1)"/."$(basename ${nome})".txt"
}

# Argumento: Arquivo com legenda
function mostra_legenda(){
    clear
    IFS=$'\n'
    tempo=0
    while read line; do
	if [ -z "$line" ]; then
	    echo
	else
	    t=$(echo $line | cut -d ' ' -f 1 -) # tempo
	    verso=$(echo $line | cut --complement -d ' ' -f 1 -) # Verso da música
	    sleep $((${t}-${tempo}))
	    tempo=$t
	    echo $verso
	fi
    done < $1
    IFS=$OLD_IFS
}

# Argumento: arquivo com música
function toca_musica(){
    echo "Tocando ${1}..."
    MUSICA=$1
    LEGENDA=$(legenda $MUSICA)
    ${TOCADOR} $1 &> /dev/null &
    pid=$!
    if [ -a ${LEGENDA} ]; then
	mostra_legenda ${LEGENDA}
    fi
    wait $pid
}

# Argumento: Um arquivo ou diretório
# Retorno: Todas as músicas existentes no diretório. Se for um arquivo,
#           retorna ele mesmo se ele for música ou "" se não for
function obtem_lista_de_musicas(){
    resultado=""
    if [ -d $1 ]; then
	for formato in $FORMATOS; do
	    resultado=${resultado}" "$(find $1 -name "*"$formato)
	done
	echo $resultado
    else
	extensao=${1##*.}
	for formato in $FORMATOS; do
	    if [ "."${extensao} = $formato ]; then
		echo $1
	    fi
	done
    fi
}

# Argumento: Uma lista de músicas separada por espaços
# Saída: Nenhuma. Uma das músicas é tocada aleatoriamente
function toca_musica_em_lista(){
    if [ $# -eq 0 ]; then
	return
    fi
    num=$(echo "$1" | wc -w)
    escolha=$((${RANDOM}%${num}))
    i=0
    for musica in $1; do
	if [ $i -eq $escolha ]; then
	    if [ $musica != "$ULTIMA_MUSICA" ]; then
		toca_musica $musica
	    fi
	    ULTIMA_MUSICA=$musica
	    break
	fi
	i=$(($i+1))
    done
}

# Argumento: Uma string
# Saída: Lista de arquivos e diretórios do $DIR_MUSICA que contém
#         a string no nome (case insensitive)
function obtem_arquivos(){
    resposta=$(find ${DIR_MUSICA} -iname "*${1}*")
    echo $resposta
}

function obtem_lista(){
    resposta=""
    if [ -a $1 ]; then
	resposta=$(obtem_lista_de_musicas $1)
    else
	arquivos=$(obtem_arquivos $1)
	for arquivo in $arquivos; do
	    resposta="${resposta} "$(obtem_lista_de_musicas $arquivo)
	done
    fi
    echo $resposta
}

# Função usada para gerar a legenda à partir de arquivo de base (arg1) e
# arquivo de destino (arg2) baseado no tempo que usuário leva para teclar
# ENTER
function gera_legenda(){
    dst=$2
    base=$(cat $1)
    IFS=$'\n'
    offset=0
    inicio=0
    sec=0
    i=0
    linha_real=""
    exec 5<> $1
    for linha in $base; do
	read linha_real <&5
	while [ -z "$linha_real" ]; do
	    if [ $offset -ne 0 ]; then
		echo >> $dst
	    fi
	    read linha_real <&5
	done
	if [ $offset -eq 0 ]; then
	    # A primeira linha é o título
	    echo "0 ${linha}" > $dst
	    offset=$(($offset+1))
	    inicio=$(date +%s)
	    continue
	fi
	clear
	tail $dst
	i=0
	for linha2 in $base; do
	    if [ $((i)) -ge $((offset)) ] && [ $((i)) -lt $(($offset+5)) ]; then
		echo $linha2
	    fi
	    i=$(($i+1))
	done
	read
	sec=$(date +%s)
	echo "$(($sec-$inicio)) ${linha}" >> $dst
	offset=$(($offset+1))
    done
    exec 5>&-
    IFS=$OLD_IFS
}


################
##### MAIN #####
################

OLD_IFS=$IFS
ULTIMA_MUSICA=""
lista=""
if [ $# -eq 0 ]; then
    lista=$(obtem_lista_de_musicas $DIR_MUSICA)
else
    if [ $1 = "-l" ]; then
	if [ $# -eq 3 ]; then
	    leg=$(legenda $3)
	    toca_musica $3 &> /dev/null &
	    gera_legenda $2 $leg
	else
	    echo "Para gerar legendas: toca -l LEGENDA_BASE MUSICA"
	fi
	exit
    else
	for arg in $*; do
	    lista="${lista} "$(obtem_lista $arg)
	done
    fi
fi
num=$(echo "$lista" | wc -w)
if [ $num -eq 0 ]; then
    exit
elif [ $num -eq 1 ]; then
    toca_musica_em_lista "$lista"
else
    while true; do
	toca_musica_em_lista "$lista"
    done
fi
