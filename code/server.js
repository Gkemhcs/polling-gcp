const express=require("express")
const app=express()
const bodyParser=require("body-parser")
app.set("view engine","ejs")
app.use(express.static("public"))
var {Datastore}=require("@google-cloud/datastore")
var datastore=new Datastore({projectId:process.env.PROJECT_ID})
var kind="app-poll"
async function  getCount(app){
const query=datastore.createQuery("app-poll").filter("appname","=",app)
const [response]=await datastore.runQuery(query)
 
let count= Number(response[0].count)
if(!count){
    count=0
}
return count
}
async function getCountList(){
    const query=await datastore.createQuery("app-poll").select(["count"])
   var list=[]
   const [data]=await datastore.runQuery(query)
   data.forEach((element)=>{
   
    list.push(Number(element.count))
   })
   return list
   
}
async function updateData(app){
const taskkey=datastore.key(["app-poll",app])
let value=await getCount(app)
 
const items=[{name:"appname",value:app},{name:"count",value: value+1}]
const task={
    key: taskkey,
    data: items
}
await datastore.upsert(task)
console.log("success")
}

app.get("/",(req,res)=>{
    res.render("polling")
})
app.use(bodyParser.urlencoded({extended:true}))
app.post("/submit",async (req,res)=>{
    await updateData(req.body.app)
    res.render("submit",{choice:req.body.app})
})
app.get("/result",async (req,res)=>{
    const list=await getCountList()
    res.render("result",{results:list})
})




 
app.get("/results",async(req,res)=>{
const list=await getCountList()
res.json({results:list})
})

app.listen(8080,()=>{
    console.log("server started")
})