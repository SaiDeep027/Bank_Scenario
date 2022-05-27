A) BANK SCENARIO:

Business Rules:

The combination of bank_id and account_id is unique. 
If the same record exists reject that record in to the error table.

Length of the account_id column cannot be < 7
Length of the account_id column cannot be > 11

The first letter of the account ID tells the type of account
Valid values for the type of account is C, S and D
Other than the first letter of the account_ID everything else will be only 
numbers.

Create an error file which contains the records which are rejected.

Target_account table:

BankID | Account_type | Account_no

Bank_error_records table:

Seq_no | Record | Reason:

Create table bank_src
(Bank_id varchar2(10),
Account_id varchar2(20));
create sequence seq_bank;
insert all
into bank_src values('A1020','S30495345')
into bank_src values('A1020','S234234432')
into bank_src values('A1020','C34534543')
into bank_src values('A1020','C34595044')
into bank_src values('A1020','C2304985345')
into bank_src values('A1020','D934530945')
into bank_src values('A1020','D940404984')
into bank_src values('A1020','D02340494R')
into bank_src values('A1021','S3405935845')
into bank_src values('A1021','S950504840')
into bank_src values('A1021','S94040958')
into bank_src values('A1021','C34095345')
into bank_src values('A1021','C08548494')
into bank_src values('A1021','C88594048')
into bank_src values('A1021','D9440021')
into bank_src values('A1021','D4954896')
select * from dual;

Create table bank_target
(bank_id varchar2(10),
Account_type char(1),
Account_id varchar2(20)
);

Create table bank_error
(seq_bank number(10),
Account_id varchar2(20),
Reason varchar2(20)
);

create sequence seq_bank;

select * from bank_src;
select * from bank_target;
select * from bank_error;

Declare
cursor cur_src is (select bank_id,account_id 
from bank_src);
v_count1 number;
v_count2 number;
Begin
for i in cur_src loop
select count(1) into v_count1 
from bank_target 
where bank_id=i.bank_id and account_id=i.account_id;
if v_count1 = 0 and substr(i.account_id,1,1) in ('S','C','D','s','c','d') and 
length(i.account_id) >=7 and length(i.account_id)<11 and 
(regexp_like(substr(account_id,2),'^[0-9]+$')) OR
(regexp_like(substr(account_id,-2),'[A-Z]$')) then
insert into bank_target values(i.bank_id,substr(i.account_id,1,1),i.account_id);
else
insert into bank_error values(seq_bank.nextval,i.bank_id,i.account_id);
end if;
end loop;
exception
when DUP_VAL_ON_INDEX then
dbms_output.put_line('value already exists');
End;

B) GUEST_CUSTOMER TABLES:

Business Rule to process the data. We get inquiries from multiple sources
while running business. 
All the inquiry’s (name, phone no etc) will be stored in a table called Guests. 
End of week, we process the guests records based on the rules mentioned below. 
Create a stored procedure to process the guests table.

Create table guests1
(name varchar2(20),
Phone number(10),
City varchar2(20),
Pro_flg char(1));

insert into guests1 (name,phone,city) values('rajesh',783738,'blr');
insert into guests1 (name,phone,city) values('bala',78939,'chn');
insert into guests1 (name,phone,city) values('arun',892393,'del');
insert into guests1 (name,phone,city) values('john',770260,'blr');
insert into guests1 (name,phone,city) values('gundu',77026089,'blr');
insert into guests1 (name,phone,city) values('tom',8555900,'hyd');

select * from guests1;

Create table customer_guest1
(c_id number(4),
c_nm varchar2(20),
c_phone number(10),
c_city varchar2(20));

insert into customer_guest1 values(1,'raj',12345,'blr');
insert into customer_guest1 values(2,'rani',989734,'hyd');
insert into customer_guest1 values(3,'kimm',878384,'chn');
insert into customer_guest1 values(4,'rajesh',783738,'blr');
insert into customer_guest1 values(6,'arun',892393,'del');

select * from customer_guest1;

create table call1
(call_id number(10),
c_nm varchar2(20),
phone number(10),
city varchar2(20));

select * from call1;

1. Process all the Guest Records
2. If the Guest name, phone and city exists in customer, 
then delete that record in Guest table.
3. If that Guest does not exists, then insert that guest record to call table 
so that call center resources call them
4. After inserting the Guest record into call table, update the pro_flg of 
Guest table to "y";

select * from guests1;

create sequence seq_call;

create or replace procedure sp_gust as
g_name number;
cursor c is select *
from guests1;
v_rec guests1%rowtype;
begin
open c;
loop
fetch c into v_rec;
exit when c%notfound;
select count(c_nm) into g_name
from customer_guest1
where c_nm=v_rec.name and c_phone=v_rec.phone and c_city=v_rec.city;
if g_name>0 then 
delete from guests1
where name=v_rec.name and phone=v_rec.phone and city=v_rec.city;
elsif g_name=0 then
insert into call1 values(seq_call.nextval,v_rec.name,v_rec.phone,v_rec.city);
update guests1
set pro_flg='Y' 
where name=v_rec.name and phone=v_rec.phone and city=v_rec.city;
end if;
end loop;
close c;
end;

exec sp_gust;