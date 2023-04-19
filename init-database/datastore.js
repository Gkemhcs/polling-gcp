 const {Datastore}= require("@google-cloud/datastore")
const datastore=new Datastore({projectId: process.env.PROJECT_ID})
async function initDatabase(){
const instagramKey=datastore.key(["app-poll","instagram"])
const facebookKey=datastore.key(["app-poll","facebook"])
const whatsappKey=datastore.key(["app-poll","whatsapp"])
const twitterKey=datastore.key(["app-poll","twitter"])
const twitterData={appname: "twitter",count:0}
const facebookData={appname: "facebook",count:0}
const whatsappData={appname: "whatsapp",count:0}
const instagramData={appname:"instagram",count:0}
const entities=[
    {key:whatsappKey,data:whatsappData},
    {key:facebookKey,data:facebookData},
    {key:twitterKey,data:twitterData},
    {key:instagramKey,data:instagramData}
]
await datastore.insert(entities)
console.log("successfully initialised the database")

}
initDatabase();