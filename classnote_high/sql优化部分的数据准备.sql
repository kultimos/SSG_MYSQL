-- 数据准备阶段
create database atguigudb2;

use atguigudb2;

CREATE TABLE `class` (
                         `id` INT(11) NOT NULL AUTO_INCREMENT,
                         `className` VARCHAR(30) DEFAULT NULL,
                         `address` VARCHAR(40) DEFAULT NULL,
                         `monitor` INT NULL ,
                         PRIMARY KEY (`id`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

CREATE TABLE `student` (
                           `id` INT(11) NOT NULL AUTO_INCREMENT,
                           `stuno` INT NOT NULL ,
                           `name` VARCHAR(20) DEFAULT NULL,
                           `age` INT(3) DEFAULT NULL,
                           `classId` INT(11) DEFAULT NULL,
                           PRIMARY KEY (`id`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

set global log_bin_trust_function_creators=1;

DELIMITER //
CREATE FUNCTION rand_string(n INT) RETURNS VARCHAR(255)
BEGIN
    DECLARE chars_str VARCHAR(100) DEFAULT
        'abcdefghijklmnopqrstuvwxyzABCDEFJHIJKLMNOPQRSTUVWXYZ';
    DECLARE return_str VARCHAR(255) DEFAULT '';
    DECLARE i INT DEFAULT 0;
    WHILE i < n DO
            SET return_str =CONCAT(return_str,SUBSTRING(chars_str,FLOOR(1+RAND()*52),1));
            SET i = i + 1;
END WHILE;
RETURN return_str;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION rand_num (from_num INT ,to_num INT) RETURNS INT(11)
BEGIN
    DECLARE i INT DEFAULT 0;
    SET i = FLOOR(from_num +RAND()*(to_num - from_num+1)) ;
RETURN i;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE insert_stu( START INT , max_num INT )
BEGIN
    DECLARE i INT DEFAULT 0;
    SET autocommit = 0; #设置手动提交事务
REPEAT #循环
    SET i = i + 1; #赋值
INSERT INTO student (stuno, name ,age ,classId ) VALUES
        ((START+i),rand_string(6),rand_num(1,50),rand_num(1,1000));
    UNTIL i = max_num
END REPEAT;
COMMIT; #提交事务
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE `insert_class`( max_num INT )
BEGIN
    DECLARE i INT DEFAULT 0;
    SET autocommit = 0;
    REPEAT
SET i = i + 1;
INSERT INTO class ( classname,address,monitor ) VALUES
    (rand_string(8),rand_string(10),rand_num(1,100000));
UNTIL i = max_num
END REPEAT;
COMMIT;
END //
DELIMITER ;

CALL insert_class(10000);
CALL insert_stu(100000,500000);


-- 删除某表上的索引,会在后续用到