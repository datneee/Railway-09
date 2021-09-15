-- Question 1: Viết lệnh để lấy ra danh sách nhân viên và thông tin phòng ban của họ

SELECT 
    *
FROM
    `Account` a
        JOIN
    department d ON a.departmentID = d.departmentID;
    
    
-- Question 2: Viết lệnh để lấy ra thông tin các account được tạo sau ngày 20/12/2020

SELECT 
    *
FROM
    `Account` a
        JOIN
    department d ON a.departmentID = d.departmentID
WHERE 
	a.createDate > '2020-12-20';
    
    
-- Question 3: Viết lệnh để lấy ra tất cả các developer

SELECT 
    *
FROM
    `Account` a
        JOIN
    `Position` p ON a.PositionID = p.PositionID
WHERE
    p.PositionName = 'Dev';
    
    
-- Question 4: Viết lệnh để lấy ra danh sách các phòng ban có >= 2 nhân viên

SELECT 
    *
FROM
    Department d
        JOIN
    `Account` a ON d.departmentID = a.departmentID
GROUP BY a.departmentID
HAVING COUNT(a.AccountID) >= 2;


-- Question 5: Viết lệnh để lấy ra danh sách câu hỏi được sử dụng trong đề thi nhiều nhất
CREATE VIEW Questions_used_in_exam AS
	SELECT 
		q.QuestionID,
		q.Content,
		q.CategoryID,
		eq.ExamID,
		COUNT(q.QuestionID) AS So_luong
	FROM
		Question q
			JOIN
		examquestion eq ON q.questionID = eq.QuestionID
	GROUP BY q.QuestionID;
SELECT 
	QuestionID, Content, CategoryID, ExamID, So_luong AS `MAX`
FROM 
	Questions_used_in_exam
WHERE
	So_luong = (	
						SELECT 
							MAX(So_luong)
						FROM 
							Questions_used_in_exam
                        );


-- Question 6: Thông kê mỗi category Question được sử dụng trong bao nhiêu Question

SELECT 
    cq.CategoryID,
    cq.CategoryName,
    COUNT(q.QuestionID) AS So_lan_su_dung_trong_question
FROM
    CategoryQuestion cq
        JOIN
    question q ON cq.categoryID = q.categoryID
GROUP BY cq.categoryID;


-- Question 7: Thông kê mỗi Question được sử dụng trong bao nhiêu Exam
SELECT 
    eq.QuestionID,
    COUNT(eq.QuestionID) AS So_lan_su_dung_trong_exam
FROM
    examquestion eq
        JOIN
    exam e ON eq.examID = e.examID
GROUP BY eq.questionID;



-- Question 8: Lấy ra Question có nhiều câu trả lời nhất
CREATE VIEW quality_answer_for_question AS
	SELECT 
		a.questionID, a.AnswerID, a.content, COUNT(a.content) AS answers
	FROM 
		answer a
		JOIN question q ON a.questionID = q.questionID
	GROUP BY 
		a.questionID;
SELECT 
	questionID, AnswerID, content, answers as `max_answer`
FROM 
	quality_answer_for_question
WHERE 
	answers = 	(
					SELECT 
						MAX(answers)
					FROM 
						quality_answer_for_question
				);
                
                
-- Question 9: Thống kê số lượng account trong mỗi group

SELECT 
    ga.groupID, COUNT(ga.accountID) AS quality_account_in_group
FROM
    groupaccount ga
        JOIN
    `Account` a ON ga.accountID = a.accountID
GROUP BY ga.groupID;


-- Question 10: Tìm chức vụ có ít người nhất
CREATE VIEW account_statistics AS
	SELECT 
		p.PositionName, COUNT(a.accountID) AS account_of_1_positon
	FROM
		`account` a
			JOIN
		`position` p ON a.positionID = p.positionID
	GROUP BY a.positionID;

SELECT 
	PositionName
FROM 
	account_statistics
WHERE 
	account_of_1_positon = 	(	
								SELECT 
									MIN(account_of_1_positon)
								FROM 
									account_statistics
							);
                            
                            
-- Question 11: Thống kê mỗi phòng ban có bao nhiêu dev, test, scrum master, PM


SELECT 
    d.departmentID,
    p.positionName

FROM
    department d
        CROSS JOIN
    `position` p

    



	

-- Question 12: Lấy thông tin chi tiết của câu hỏi bao gồm: thông tin cơ bản của question, loại câu hỏi, ai là người tạo ra câu hỏi, câu trả lời là gì, ...


SELECT 
	q.QuestionID AS `ID question`, q.Content AS `question`, q.CategoryID AS `ID người tạo câu hỏi`,
    q.CreateDate AS `Ngày tạo câu hỏi`, a.Content AS `Câu trả lời`, tq.TypeName AS `Kiểu câu hỏi`
FROM 
	question q 
    JOIN answer a ON q.questionID = a.questionID
    JOIN typequestion tq ON tq.typeID = q.typeID;
    


-- Question 13: Lấy ra số lượng câu hỏi của mỗi loại tự luận hay trắc nghiệm
SELECT 
    tq.typeName, COUNT(q.questionID)
FROM
    question q
        JOIN
    typequestion tq ON tq.typeID = q.typeID
GROUP BY tq.typeName;


-- Question 14:Lấy ra group không có account nào

SELECT 
    g.GroupID, g.GroupName
FROM
    `group` g
        LEFT JOIN
    groupaccount ga ON g.groupID = ga.groupID
WHERE 
	ga.accountID IS NULL;
    
    
-- Question 15: Lấy ra group không có account nào	
-- Question 16: Lấy ra question không có answer nào


SELECT 
    q.QuestionID AS `question nothing answer`
FROM
    question q
        LEFT JOIN
    answer a ON q.questionID = a.questionID
WHERE
    a.answerID IS NULL;
/* ===============UNION=========== */
/* 
 Question 17:
a) Lấy các account thuộc nhóm thứ 1
b) Lấy các account thuộc nhóm thứ 2
c) Ghép 2 kết quả từ câu a) và câu b) sao cho không có record nào trùng nhau
*/

SELECT 
    a.AccountID, a.Email, a.FullName
FROM
    `account` a
        JOIN
    groupaccount ga ON a.AccountID = ga.AccountID
WHERE
    ga.GroupID = 1
UNION
SELECT 
    a.AccountID, a.Email, a.FullName
FROM
    `account` a
        JOIN
    groupaccount ga ON a.AccountID = ga.AccountID
WHERE
    ga.GroupID = 2;
    
    
/*
Question 18:
a) Lấy các group có lớn hơn 3 thành viên
b) Lấy các group có nhỏ hơn 2 thành viên
c) Ghép 2 kết quả từ câu a) và câu b)
*/


SELECT 
    *
FROM
    `group` g
        JOIN
    groupaccount ga ON g.groupID = ga.groupID
GROUP BY ga.groupID
HAVING COUNT(ga.accountID) > 3
UNION
SELECT 
    *
FROM
    `group` g
        JOIN
    groupaccount ga ON g.groupID = ga.groupID
GROUP BY ga.groupID
HAVING COUNT(ga.accountID) < 2

