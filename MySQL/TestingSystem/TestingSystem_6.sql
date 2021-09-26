
-- Question 1: Tạo store để người dùng nhập vào tên phòng ban và in ra tất cả các account thuộc phòng ban đó
DROP PROCEDURE IF EXISTS get_accounts_in_department;
DELIMITER $$
CREATE PROCEDURE get_accounts_in_department( IN in_departmentName NVARCHAR(255))
	BEGIN
		SELECT
			d.departmentID, a.accountID, a.email, a.userName, a.fullname
        FROM 
			`account` a 
				JOIN
			department d ON d.departmentID = a.departmentID 
		WHERE d.departmentName = in_departmentName;
    END$$
DELIMITER ;
CALL get_accounts_in_department('Bảo vệ');


-- Question 2: Tạo store để in ra số lượng account trong mỗi group

DROP PROCEDURE IF EXISTS getQuality_accounts_in_group;
DELIMITER $$
CREATE PROCEDURE getQuality_accounts_in_group()
BEGIN 
	SELECT 
		ga.groupID, COUNT(a.accountID) AS quality_accounts
	FROM 
		`account` a
			JOIN 
		groupaccount ga ON ga.accountID = a.accountID
	GROUP BY ga.groupID;
END$$
DELIMITER ;
CALL getQuality_accounts_in_group();


-- Question 3: Tạo store để thống kê mỗi type question có bao nhiêu question được tạo trong tháng hiện tại

DROP PROCEDURE IF EXISTS get_question_and_type_inNow
DELIMITER $$
CREATE PROCEDURE get_question_and_type_inNow()
BEGIN
	SELECT 
		q.TypeID, IF(COUNT(q.questionID) = 0, 0, COUNT(q.questionID)) AS question_inMonth
	FROM
		question q
	WHERE MONTH(q.createDate) = MONTH(NOW())
    GROUP BY q.typeID;
	
END$$
DELIMITER ;

CALL get_question_and_type_inNow();
-- Question 4: Tạo store để trả ra id của type question có nhiều câu hỏi nhất


DROP PROCEDURE IF EXISTS popular_questionType;
DELIMITER $$
CREATE PROCEDURE popular_questionType(OUT popular_question TINYINT(3))
BEGIN
	SELECT 
		tq.typeID INTO popular_question
	FROM
		typequestion tq
			JOIN
		question q ON q.typeID = tq.typeID
	GROUP BY tq.typeID
	HAVING 
		COUNT(q.questionID) = 	(
									SELECT 
										COUNT(q.questionID)
									FROM 
										typequestion tq
											JOIN
										question q ON q.typeID = tq.typeID
									GROUP BY tq.typeID
									ORDER BY COUNT(q.questionID) DESC
									LIMIT 1
								);
END$$
DELIMITER ;

SET @is_popular_question = 0;
CALL popular_questionType(@is_popular_question);
SELECT @is_popular_question;
    
    
-- Question 5: Sử dụng store ở question 4 để tìm ra tên của type question



SELECT 
	tq.typeName
FROM 
	typequestion tq
WHERE
	tq.typeID = @is_popular_question;
    
    
    
-- Question 6: Viết 1 store cho phép người dùng nhập vào 1 chuỗi và trả về group có tên chứa chuỗi của người dùng nhập vào 
--                 hoặc trả về user có username chứa chuỗi của người dùng nhập vào


DROP PROCEDURE IF EXISTS get_group_or_userName_bySearch;
DELIMITER $$
CREATE PROCEDURE get_group_or_userName_bySearch(IN in_char NVARCHAR(255), IN in_selector TINYINT)
BEGIN
	IF in_selector = 1 THEN
		SELECT 
			*
		FROM
			`group` g
		WHERE 
			LOCATE(in_char, g.groupName) > 0;
	ELSE 
		SELECT 
			*
		FROM
			`account` a
		WHERE 
			LOCATE(in_char, a.username) > 0;
	END IF;
END$$
DELIMITER ;

CALL get_group_or_userName_bySearch('dang', 0);


-- Question 7: Viết 1 store cho phép người dùng nhập vào thông tin username, email và trong store sẽ tự động gán:
/*
username sẽ giống email nhưng bỏ phần @..mail đi
positionID: sẽ có default là developer
departmentID: sẽ được cho vào 1 phòng chờ
Sau đó in ra kết quả tạo thành công
*/
COMMIT;
DROP PROCEDURE IF EXISTS change_user;
DELIMITER $$
CREATE PROCEDURE change_user(IN in_fullname NVARCHAR(255), IN in_email VARCHAR(255))
BEGIN 
	DECLARE S_userName VARCHAR(255) DEFAULT SUBSTRING(in_email, 1, LOCATE('@',in_email) - 1);
    DECLARE S_positionID TINYINT(3) UNSIGNED DEFAULT 2;
    DECLARE S_departmentID TINYINT(3) UNSIGNED DEFAULT 10;
    DECLARE S_createDate DATETIME DEFAULT NOW();
    INSERT INTO `account`(email, userName, fullname, positionID, departmentID, createDate)
			VALUE
			(in_email, S_userName, in_fullname, S_positionID, S_departmentID, S_createDate);
	SELECT 
		*
	FROM 
		`account` a
	WHERE a.fullname = in_fullname;
END$$
DELIMITER ;
CALL change_user('Phạm Văn Đạt', 'datnull12345@gmail.com');


-- Question 8: Viết 1 store cho phép người dùng nhập vào Essay hoặc Multiple-Choice để thống kê câu hỏi essay hoặc multiple-choice nào có content dài nhất



DROP PROCEDURE IF EXISTS get_question_has_topContent;
DELIMITER $$
CREATE PROCEDURE get_question_has_topContent(IN in_typequestion ENUM('Multyple-Choice', 'Essay'))
BEGIN
	SELECT q.QuestionID, q.Content, tq.typeID, tq.typeName, LENGTH(q.content) AS forLengthContent
    FROM 
		question q
			JOIN
		typequestion tq ON q.typeID = tq.typeID
	WHERE 	tq.typeName = in_typequestion
			AND
			LENGTH(q.content) = 	(
											SELECT 
												LENGTH(q.content)
											FROM 
												question q
													JOIN
												typequestion tq ON q.typeID = tq.typeID  
											GROUP BY q.questionID
											ORDER BY LENGTH(q.content) DESC
											LIMIT 1
										);
END$$
DELIMITER ;

CALL get_question_has_topContent('Essay');


-- Question 9: Viết 1 store cho phép người dùng xóa exam dựa vào ID

COMMIT;
DROP PROCEDURE IF EXISTS delete_exam_dependantID;
DELIMITER $$
CREATE PROCEDURE delete_exam_dependantID(IN in_examID TINYINT(3) UNSIGNED)
BEGIN
	DELETE FROM exam 
	WHERE
		examID = in_examID;
	SELECT 
		*
	FROM 
		exam;
END$$
DELIMITER ;
CALL delete_exam_dependantID(10);
ROLLBACK;



-- Question 10: Tìm ra các exam được tạo từ 3 năm trước và xóa các exam đó đi (sử dụng store ở câu 9 để xóa)
--               Sau đó in số lượng record đã remove từ các table liên quan trong khi removing


DROP PROCEDURE IF EXISTS deleteExamBefore3Years;
DELIMITER $$
CREATE PROCEDURE deleteExamBefore3Years()
	BEGIN 
		DECLARE countExam TINYINT UNSIGNED DEFAULT 0;
		DECLARE	countExamQuestion TINYINT UNSIGNED DEFAULT 0;
		DECLARE i TINYINT UNSIGNED DEFAULT 1;
		DECLARE examIDNeed INT;
		DROP TABLE IF EXISTS deleteExamBefore3Years_template;
        CREATE TABLE deleteExamBefore3Years_template 
        (
			ID INT PRIMARY KEY AUTO_INCREMENT,
            examID INT
        );
        INSERT INTO deleteExamBefore3Years_template(examID) (	
																SELECT 
																	e.examID
																FROM 
																	exam e
																WHERE
																	(YEAR(NOW()) - YEAR(e.createDate) > 2)
															);
		SELECT 
			COUNT(1) INTO countExam
		FROM 
			deleteExamBefore3Years_template;
		SELECT 
			COUNT(1) INTO countExamQuestion
		FROM 
			examquesition eq
				JOIN 
			deleteExamBefore3Years_template dt ON eq.examID = dt.examID;
		WHILE i <= countExam DO
			SELECT
				examID INTO examIDNeed 
			FROM 
				deleteExamBefore3Years_template
			WHERE ID = i;
            CALL delete_exam_dependantID(examIDNeed);
            SET i = i + 1;
        END WHILE;
		
	END $$
DELIMITER ;
-- Question 11: Viết store cho phép người dùng xóa phòng ban bằng cách người dùng
--               nhập vào tên phòng ban và các account thuộc phòng ban đó sẽ được chuyển về phòng ban default là phòng ban chờ việc




-- Question 12: Viết store để in ra mỗi tháng có bao nhieu cau hỏi được tạo trong năm nay


DROP PROCEDURE IF EXISTS questionIsCreatedEachMonth;
DELIMITER $$
CREATE PROCEDURE questionIsCreatedEachMonth()
	BEGIN
		WITH months AS 
		(
			SELECT 1 AS `month`
			UNION SELECT 2 AS `month`
			UNION SELECT 3 AS `month`
			UNION SELECT 4 AS `month`
			UNION SELECT 5 AS `month`
			UNION SELECT 6 AS `month`
			UNION SELECT 7 AS `month`
			UNION SELECT 8 AS `month`
			UNION SELECT 9 AS `month`
			UNION SELECT 10 AS `month`
			UNION SELECT 11 AS `month`
			UNION SELECT 12 AS `month`
		)
        SELECT
			m.`month`, COUNT(q.questionID) AS Slg_question
		FROM 
			months m
				LEFT JOIN 
					(	
						SELECT 
							*
						FROM 
							question
						WHERE
							YEAR(createDate) = YEAR(NOW())
					)	q 
				ON m.`month` = MONTH(q.createDate)
		GROUP BY m.`month`;
	END$$
DELIMITER ;


-- Question 13: Viết store để in ra mỗi tháng có bao nhiêu câu hỏi được tạo trong năm trong 6 tháng gần nhất 


DELIMITER $$
	CREATE PROCEDURE question_in_6month()
    BEGIN
		with cte_6month as
        (
			SELECT month(now()) as m , year(now()) as y
            union
			SELECT month(date_sub(now(), interval 1 month)), year(date_sub(now(), interval 1 month)) as y
            union
			SELECT month(date_sub(now(), interval 2 month)), year(date_sub(now(), interval 2 month)) as y
            union
			SELECT month(date_sub(now(), interval 3 month)), year(date_sub(now(), interval 3 month)) as y
            union
			SELECT month(date_sub(now(), interval 4 month)), year(date_sub(now(), interval 4 month)) as y
            union
			SELECT month(date_sub(now(), interval 5 month)), year(date_sub(now(), interval 5 month)) as y
        )
        select m, y, if (count(questionid) = 0, 'khong co cau nao', count(questionid)) as total
        from cte_6month
		left join question on m = month(createdate) and y = year(createdate)
        group by m, y;
        
    END$$
DELIMITER ;
CALL question_in_6month();




































--


