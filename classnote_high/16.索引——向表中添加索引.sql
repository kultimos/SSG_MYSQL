-- 1.创建索引
--     Mysql支持多种方式在单个或多个列上创建索引:在创建表的定义语句CREATE TABLE中指定索引项,使用ALTER TABLE语句在已存在的表上创建索引,或者
--   使用CREATE INDEX语句在已存在的表上添加索引
--
-- 01-索引的创建
create database dbtest2;
use dbtest2;

-- #第一种: CREATE TABLE
-- #隐式的方式创建索引,在声明有主键约束、唯一性约束、外键约束的字段上,会自动添加相关的索引
CREATE TABLE dept (
dept_id INT PRIMARY KEY AUTO_INCREMENT,
dept_name VARCHAR(20)
);

CREATE TABLE emp (
emp_id INT PRIMARY KEY AUTO_INCREMENT,
emp_name VARCHAR(20) UNIQUE ,
dept_id INT,
CONSTRAINT emp_dept_id_fk FOREIGN KEY (dept_id) REFERENCES dept(dept_id)
);

-- 显式的方式创建
-- 1.创建普通索引
-- 在book表中的year_publication字段上建立普通索引,SQL如下
CREATE TABLE book (
book_id INT,
book_name VARCHAR(100),
author VARCHAR(100),
info VARCHAR(100),
comments VARCHAR(100),
year_publication YEAR,
#声明索引
INDEX idx_bname(book_name)
);

-- 通过命令查看索引
-- 方式1:
-- SHOW CREATE TABLE book; 不建议在idea中无法查看到详细情况,不过在服务器上可以通过末尾增加 /G 可以查看到
-- 方式2:
-- SHOW INDEX FROM book; 主要使用这种

-- 2.创建唯一索引
CREATE TABLE book1 (
book_id INT,
book_name VARCHAR(100),
author VARCHAR(100),
info VARCHAR(100),
comments VARCHAR(100),
year_publication YEAR,
UNIQUE INDEX unique_idx_cmt(comments)
);

show index from book1;
-- 创建唯一性索引后,向表中插入数据时,该字段的值就不可以重复
insert into book1 (book_id, book_name, author, info, comments, year_publication)
values (2,'ss','玩啊wq玩','eew','我不能重复',YEAR('2023-03-05'));

-- 连续执行以后就会有如下报错:  Duplicate entry '我不能重复' for key 'book1.unique_idx_cmt'
insert into book1 (book_id, book_name, author, info, comments, year_publication)
values (2,'ss','玩啊wq玩','eew','我不能重复',YEAR('2023-03-05'));

-- 唯一性索引不可以插入重复的值,但是可以重复添加null值;
insert into book1 (book_id, book_name, author, info, comments, year_publication)
values (3,'ss','玩啊wq玩','eew',null,YEAR('2023-03-05'));

insert into book1 (book_id, book_name, author, info, comments, year_publication)
values (4,'ww','上午','问问',null,YEAR('2023-03-16'));

-- 3.主键索引
-- 主键索引就是通过定义主键约束的方式定义主键索引
CREATE TABLE book2 (
book_id INT PRIMARY KEY ,
book_name VARCHAR(100),
author VARCHAR(100),
info VARCHAR(100),
comments VARCHAR(100),
year_publication YEAR
);
SHOW INDEX FROM book2;

-- 可以通过删除主键约束的方式删除主键索引
ALTER TABLE book2 DROP PRIMARY KEY;

-- 4.创建单列索引
CREATE TABLE book3 (
book_id INT,
book_name VARCHAR(100),
author VARCHAR(100),
info VARCHAR(100),
comments VARCHAR(100),
year_publication YEAR,
INDEX single_idx_bn(book_name)
);
SHOW INDEX FROM book3;

-- 5.创建联合索引
CREATE TABLE book4 (
book_id INT,
book_name VARCHAR(100),
author VARCHAR(100),
info VARCHAR(100),
comments VARCHAR(100),
year_publication YEAR,
INDEX all_idx_bn(book_id,book_name,info)
);
SHOW INDEX FROM book4;

select * from book4 where book_id=1 and book_name = '三国演义';
 explain select * from book4 where book_id=1 and book_name = '三国演义'; -- 会使用到联合索引
explain select * from book4 where book_name = '水浒传'; -- 无法使用联合索引

-- 6.创建全文索引
CREATE TABLE book5 (
book_id INT,
book_name VARCHAR(100),
author VARCHAR(100),
info VARCHAR(100),
comments VARCHAR(100),
year_publication YEAR,
fulltext INDEX ft_idx_author(author(50))
);
--  这里表示以author的前50个字符作为索引,如果两行数据的author前50个字符恰好相等,那就都会被查出来,
--  这样设计主要是考虑本身全文检索就是针对大数据量做查询,如果字段过长,索引占据的空间也会相对更大;
SHOW INDEX FROM book5;

-- 并且全文检索是支持联合索引的
CREATE TABLE book6 (
book_id INT,
book_name VARCHAR(100),
author VARCHAR(100),
info VARCHAR(100),
comments VARCHAR(100),
year_publication YEAR,
fulltext INDEX all_fulltext_idx_ac(author,comments)
);
SHOW INDEX FROM book6;
-- like模糊查询
SELECT * FROM book6 where comments LIKE '%查询字符串%';
-- 全文检索引用match+against方式查询
SELECT * FROM book6 WHERE MATCH(author,comments) AGAINST ('待查字符串');
-- 注意点
-- 1.使用全文检索前,搞清楚版本状况
-- 2.全文检索比like+% 要快n倍,但是可能存在经度问题
-- 3.如果需要全文检索的大量数据,建议先添加数据,再创建索引


-- 第二种: 表已经成功创建,再去给表增加一个索引
CREATE TABLE book7 (
book_id INT,
book_name VARCHAR(100),
author VARCHAR(100),
info VARCHAR(100),
comments VARCHAR(100),
year_publication YEAR
);
SHOW INDEX FROM book7;
-- 1.ALTER TABLE ... ADD ...
Alter TABLE book7 ADD primary key (book_id);    -- 添加一个主键即添加一个主键索引
Alter TABLE book7 ADD INDEX index_info(info);   -- 添加一个普通索引

-- 2.CREATE INDEX ... ON ...
CREATE INDEX auth_index ON book7(author);
