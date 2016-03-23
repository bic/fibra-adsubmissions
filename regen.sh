#if [ -d 'fibra-gen' ];  then
#    rm -fr fibra-gen
#fi


#(cd kitchen-site; meteor-kitchen ./meteor-kitchen.json ../kitchen-site-gen ; cd ../kitchen-site-gen)

mongo localhost:4001/meteor --quiet \
--eval 'db.applications.find().toArray().forEach(function(x){shellPrint(" echo downloading "+x.data.application.title+";wget http://localhost:4000/api/getapp/json/" + x._id + " -O application.json" )})' \
| grep adsubmission - | sh


#PACKAGE_DIRS must be set because meteor kitchan can call meteor
PACKAGE_DIRS=`pwd`/packages:`pwd`../../fulger/meteor_packages  meteor-kitchen --jade application.json fibra-gen
#patch -p0 <patch.diff
#meteor-kitchen http://www.meteorkitchen.com/api/getapp/json/dSj5LxLQBAdPjAxiJ fibra-gen



