


-- Question 1.............

-- Question 2: Lấy ra tất cả các phòng ban

SELECT 
    *
FROM
    department;
    
-- Question 3: Lấy ra id của phòng ban 'sale'
SELECT 
    *
FROM
    department d
WHERE
    d.DepartmentName = 'Sale';

-- Question 4: Lấy ra thông tin của account có full name dài nhất

SELECT 
	*
FROM 
	`Account`;
--
SELECT 
	*
FROM 
	`Account` a
WHERE LENGTH(a.fullname) = (
								SELECT MAX(LENGTH(a.fullname))
								FROM `Account` a	
							);
                            
                            
-- Question 5: Lấy ra thông tin account có full name dài nhất và thuộc phòng ban có id = 3

SELECT 
    *
FROM
    `Account` a
WHERE
    LENGTH(a.fullname) = 	(
								SELECT 
									MAX(LENGTH(a.fullname))
								FROM 
									`Account` a
								WHERE a.departmentID = 3
							);

-- Question 6: Lấy ra tên group đã tham gia trước ngày 20/12/2019

SELECT 
    GroupName
FROM
    `Group` g
WHERE
    g.createDate < '2019-12-20';
    
-- Question 7: Lấy ra id của question có >= 4 câu trả lời


SELECT 
    a.QuestionID
FROM
    answer a
GROUP BY a.QuestionID
HAVING COUNT(a.Content) >= 4;

-- Question 8: Lấy ra các mã đề thi có thời gian thi >= 120 phút và được tạo trước ngày 20/12/2019

SELECT 
    *
FROM
    Exam e
WHERE 
	e.Duration >= 120;
    
-- Question 9: Lấy ra 5 group được tạo gần đây nhất

SELECT 
    *
FROM
    `group` g
ORDER BY g.createDate DESC
LIMIT 5;

-- Question 10: Đếm số nhân viên thuộc department có id = 2

SELECT 
    d.departmentID, COUNT(a.accountID) AS Account_in_department
FROM
    `Account` a
        JOIN
    department d ON a.departmentID = d.departmentID
GROUP BY d.departmentID;

-- Question 11: Lấy ra nhân viên có tên bắt đầu bằng chữ "D" và kết thúc bằng chữ "o"
SELECT 
	*
FROM 
	`Account` a
WHERE a.username LIKE 'D%k';

-- Question 12: Xóa tất cả các exam được tạo trước ngày 20/12/2019
SELECT 
	* 
FROM 
	exam;
COMMIT;

DELETE FROM Exam
WHERE 
	createDate < '2019-12-20';
ROLLBACK;

-- Question 13........

-- Question 14 Update thông tin của account có id = 5 thành tên "Nguyễn Bá Lộc" và email thành loc.nguyenba@vti.com.vn

UPDATE `Account` AS a 
SET 
    a.fullname = 'Nguyễn Bá Lộc',
    a.email = 'loc.nguyenba@vti.com.vn'
WHERE
    a.accountID = 5;

-- Question 15 .................














