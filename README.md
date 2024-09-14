# SuiPet
目前SuiPet中所涉及的所有NFT图片已经上传至walrus，网站部署地址：https://ppcrgfwi58d6m81yobkipe37uvcr50w5ouuasm14livks9not.walrus.site
网站id：ppcrgfwi58d6m81yobkipe37uvcr50w5ouuasm14livks9not
视频id:gpS7ldWithDwN2Tt4FMe7W5mM0h_2jP9lCtIERHGbBo
客户端：https://github.com/gonahot/client/tree/main/subpet

## 项目说明
SuiPet是Sui上的一款成长性宠物，以NFT换装为核心逻辑同时内置题库，使得学习的过程变得不再枯燥。<br>
在游戏中，玩家需要通过签到和答题来获得积分并提高宠物等级，用积分换购服饰，让宠物的形象更加多变。<br>
题库可以引进外界平台，也就是说，宠物可以紧紧地与你目前的学习相关联，你能在学习中获得极大的乐趣！

## 游戏流程
1. 链接钱包
在连接SUI Wallet的同时，生成一个用户的结构体存在地址之下
2. mint宠物
mint出一个初始形象的宠物发送给用户（宠物会动喔
3. 每日签到
每天签到将会获得2个积分，可以用来换取盲盒服饰
4. 答题
回答问题可以获得对应积分，内置题库允许和各类学习平台对接
5. 兑换服饰
花费10个积分，可以在服饰页面换取服饰盲盒，让宠物穿上它！
*“action”类的配饰会覆盖其他原有的配饰！*


## 接口说明
`create_user`: 不需要传参，发送一个创建新用户的事件（包括用户id,地址,总分）<br>
`create_pet`: 传入宠物的名字，发送一个创建宠物的事件(包括宠物id,名字,用户的地址）<br> 
`mint_item`: 传入配饰类型和用户id，用户获得服饰 <br>
`update_pet`: 传入一个宠物id，更新宠物等级 <br>
### 类型
目前有3个配饰类型：行为，帽子，衣服（行为展示时，其他服饰不可见）<br> 
const Type_cap:u64 = 1; <br>
const Type_action:u64 = 2; <br>
const Type_item:u64 = 3; <br>

## 函数说明
`add_score`:增加用户积分 传入用户ID和增加的数量 <br>
`remove_item_from_pet`:从宠物上脱下服饰  传入宠物id和配饰id <br>
`add_item_to_pet`:让宠物穿上服饰  传入宠物id和服饰类型 <br>
