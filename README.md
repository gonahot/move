# StuPet

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
