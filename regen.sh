#if [ -d 'fibra-gen' ];  then
#    rm -fr fibra-gen
#fi

meteor-kitchen http://www.meteorkitchen.com/api/getapp/json/dSj5LxLQBAdPjAxiJ fibra-gen

(cd fibra-gen; meteor)
