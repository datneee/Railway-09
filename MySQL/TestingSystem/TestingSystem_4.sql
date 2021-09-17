-- Question 1: Viết lệnh để lấy ra danh sách nhân viên và thông tin phòng ban của họ
SELECT 
	a.AccountID, a.Email, a.UserName, a.FullName, a.PositionID, a.CreateDate, d.DepartmentID, d.DepartmentName
FROM 
	`account` a 
		JOIN 
	department d ON a.departmentID = d.departmentID ;

-- Question 2: Viết lệnh để lấy ra thông tin các account được tạo sau ngày 20/7/2020


SELECT 
	a.AccountID, a.Email, a.UserName, a.FullName, a.PositionID, a.CreateDate
FROM 
	`account` a 
		JOIN 
	department d ON a.departmentID = d.departmentID
WHERE a.createDate > "2020-07-20";


-- Question 3: Viết lệnh để lấy ra tất cả các developer

SELECT 
	a.accountID, a.email, a.username, a.fullname, p.positionName
FROM 
	`account` a 
		JOIN 
	`position` p ON a.positionID =  p.positionID
WHERE 
	p.positionName = "dev";
    
    
-- Question 4: Viết lệnh để lấy ra danh sách các phòng ban có >= 2 nhân viên


SELECT 
	d.departmentID, d.departmentName, COUNT(a.accountID) AS statistics_Accs
FROM 
	department d 
		JOIN 
	`account` a ON a.departmentID = d.departmentID
GROUP BY 	
	a.departmentID
HAVING COUNT(a.accountID) >= 2;


-- Question 5: Viết lệnh để lấy ra danh sách câu hỏi được sử dụng trong đề thi nhiều nhất

SELECT 
    q.questionID, q.content, q.CategoryID, q.TypeID, q.CreatorID, q.CreateDate, COUNT(eq.examID) AS statistics_exams
FROM
    question q
        JOIN
    examquestion eq ON q.questionID = eq.questionID
GROUP BY
	q.questionID
HAVING
	COUNT(eq.examID) = 	(	
							SELECT 
								COUNT(eq.examID)
							FROM
								question q
									JOIN
								examquestion eq ON q.questionID = eq.questionID
							GROUP BY
								q.questionID
							ORDER BY COUNT(eq.examID) DESC
                            LIMIT 1
						);
                        
                        
-- Question 6: Thông kê mỗi category Question được sử dụng trong bao nhiêu Question

SELECT 
	cq.CategoryID, cq.CategoryName, COUNT(q.QuestionID) AS statistics_questions
FROM
	categoryquestion cq
		JOIN
	question q ON q.categoryID = cq.categoryID
GROUP BY q.categoryID;

-- Question 7: Thông kê mỗi Question được sử dụng trong bao nhiêu Exam


SELECT 
	q.QuestionID, q.Content, COUNT(eq.ExamID) AS statistics_exams
FROM 
	question q
		JOIN
	examquestion eq ON q.questionID = eq.questionID
GROUP BY q.QuestionID;


-- Question 8: Lấy ra Question có nhiều câu trả lời nhất


SELECT 
	q.questionID, q.content, COUNT(a.AnswerID) AS statistics_answers
FROM
	question q
		JOIN
	answer a ON q.questionID = a.questionID
GROUP BY a.questionID
HAVING 
	COUNT(a.AnswerID) = 	(
								SELECT 
									COUNT(a.answerID)
                                 FROM
									question q
										JOIN
									answer a ON q.questionID = a.questionID
								GROUP BY a.questionID
                                ORDER BY COUNT(a.answerID) DESC
                                LIMIT 1
                            );
                            
                            
-- Question 9: Thống kê số lượng account trong mỗi group

SELECT 
    ga.groupID, COUNT(ga.AccountID) AS statistics_Accs 
FROM
    groupaccount ga
GROUP BY ga.groupID;

-- Question 10: Tìm chức vụ có ít người nhất



SELECT 
	p.positionID, p.PositionName, COUNT(a.AccountID) AS Min_Account
FROM
	`position` p
		JOIN
	`account` a ON a.positionID = p.positionID
GROUP BY a.positionID
HAVING 
	COUNT(a.AccountID) = 	(
								SELECT 
									COUNT(a.AccountID)
                                 FROM
									`position` p
										JOIN
									`account` a ON a.positionID = p.positionID
								GROUP BY a.positionID
                                ORDER BY COUNT(a.AccountID) ASC
                                LIMIT 1
                            );




-- Question 11: Thống kê mỗi phòng ban có bao nhiêu dev, test, scrum master, PM

SELECT 
	d.DepartmentID,
	IF (LOCATE('dev',p.positionName) > 0, COUNT(p.positionID), 0) AS Dev,
	IF (LOCATE('test',p.positionName) > 0, COUNT(p.positionID), 0) AS Test,
	IF (LOCATE('scrum master',p.positionName) > 0, COUNT(p.positionID), 0) AS Scrum_Master,
	IF (LOCATE('PM',p.positionName) > 0, COUNT(p.positionID), 0) AS PM
FROM
	department d
		JOIN
	`account` a ON a.departmentID = d.departmentID
		JOIN
	`position` p ON p.positionID = a.positionID
GROUP BY d.departmentID, p.positionID
ORDER BY d.departmentID;
	

-- Question 12: Lấy thông tin chi tiết của câu hỏi bao gồm: thông tin cơ bản của
--              question, loại câu hỏi, ai là người tạo ra câu hỏi, câu trả lời là gì, ...


SELECT 
	q.QuestionID, q.content, q.typeID, q.CreatorID, a.fullname, ans.Content, ans.isCorrect
FROM 
	question q 
		JOIN 
	answer ans ON q.questionID = ans.questionID
		JOIN 
	`account` a ON a.accountID = q.creatorID;


-- Question 13: Lấy ra số lượng câu hỏi của mỗi loại tự luận hay trắc nghiệm

SELECT 
    tq.TypeName, COUNT(q.questionID) AS statistics_question
FROM
    typequestion tq
        JOIN
    question q ON q.typeID = tq.typeID
GROUP BY q.typeID;


-- Question 14:Lấy ra group không có account nào


SELECT 
    g.GroupID
FROM
    `group` g
        LEFT JOIN
    groupaccount ga ON ga.groupID = g.groupID 
WHERE 
	ga.accountID IS NULL;
    
    
-- Question 15: Lấy ra group không có account nào ( giống câu 14 ) 

-- Question 16: Lấy ra question không có answer nào



SELECT
	q.QuestionID, q.content
FROM 
	question q 
		LEFT JOIN 
	answer a ON a.questionID = q.questionID
WHERE
	a.answerID IS NULL;    
    
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

