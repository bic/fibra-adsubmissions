

mv fibra-deploy fibra-deploy`date +%s`
mkdir -p fibra-deploy/packages
cp -r files/kitchen-settings fibra-deploy/packages

mongo localhost:4001/meteor --quiet \
--eval 'db.applications.find().toArray().forEach(function(x){shellPrint(" echo downloading "+x.data.application.title+";wget http://localhost:4000/api/getapp/json/" + x._id + " -O application.json" )})' \
| grep adsubmission - | sh
cp application.json fibra-deploy/packages/kitchen-settings/


#PACKAGE_DIRS must be set because meteor kitchan can call meteor
PACKAGE_DIRS=`pwd`/packages:`pwd`../../fulger/meteor_packages  meteor-kitchen --jade application.json fibra-deploy

cd fibra-deploy/packages
find  ../../packages/* ../../../fulger/meteor_packages/* -type d -prune  | xargs -I'{}' -n1   echo ln -s {} . | sh
cd ../..
