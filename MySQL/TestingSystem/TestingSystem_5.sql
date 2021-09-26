-- Question 1: Tạo view có chứa danh sách nhân viên thuộc phòng ban sale
DROP VIEW IF EXISTS accoutSales;
CREATE VIEW  accoutSales AS
	SELECT 
		a.AccountID,
		a.Email,
		a.UserName,
		a.FullName,
		a.PositionID,
		a.CreateDate,
		d.departmentID,
		d.departmentName
	FROM
		`account` a
			JOIN
		department d ON a.departmentID = d.departmentID
	WHERE
		d.departmentName = 'sale';
        

-- Question 2: Tạo view có chứa thông tin các account tham gia vào nhiều group nhất

SELECT 
    a.AccountID,
    a.Email,
    a.UserName,
    a.FullName,
    a.PositionID,
    a.CreateDate,
    ga.GroupID,
    COUNT(ga.GroupID) AS maxQuality_account_inGroup
FROM
    `account` a
        JOIN
    groupaccount ga ON ga.accountID = a.accountID
GROUP BY a.accountID
HAVING COUNT(ga.groupID) = 	(
								SELECT 
									COUNT(ga.groupID)
								FROM 
									`account` a
										JOIN
									groupaccount ga ON ga.accountID = a.accountID
								GROUP BY a.accountID
                                ORDER BY COUNT(ga.groupID) DESC
                                LIMIT 1
                            );
                            
                            
-- Question 3: Tạo view có chứa câu hỏi có những content quá dài (content quá 70 từ được coi là quá dài) và xóa nó đi
COMMIT;
DROP VIEW IF EXISTS logAndelete_Longquestion;
CREATE VIEW logAndelete_Longquestion AS
	SELECT 
		*
	FROM
		question q
	WHERE
		LENGTH(q.content) >= 70;
	DELETE FROM question 
	WHERE
		LENGTH(question.content) >= 70  ;


-- Question 4: Tạo view có chứa danh sách các phòng ban có nhiều nhân viên nhất

DROP VIEW IF EXISTS department_hav_qualityAccountMax;
CREATE VIEW department_hav_qualityAccountMax AS
	SELECT 
		d.DepartmentID, d.DepartmentName, COUNT(a.AccountID) AS qualityAccounts
	FROM
		department d
			JOIN
		`account` a ON d.departmentID = a.departmentID
	GROUP BY d.departmentID
	HAVING 
		COUNT(a.AccountID) = 	(
									SELECT 
										COUNT(a.AccountID)
									FROM
										department d
											JOIN
										`account` a ON d.departmentID = a.departmentID
									GROUP BY d.departmentID
									ORDER BY COUNT(a.AccountID) DESC
									LIMIT 1
								);


-- Question 5: Tạo view có chứa tất các các câu hỏi do user họ Nguyễn tạo

DROP VIEW IF EXISTS first_appearance;
CREATE VIEW  first_appearance AS
	SELECT 
		q.QuestionID, q.Content, q.CategoryID, q.TypeID, q.CreateDate, q.CreatorID, a.fullname
	FROM 
		question q
			JOIN
		`account` a ON a.accountID = q.CreatorID
	WHERE 
		LOCATE('Nguyễn',a.fullname) = 1;
