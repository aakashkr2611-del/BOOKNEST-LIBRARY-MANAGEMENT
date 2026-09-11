-- Complete setup script for BookNest Library System
-- Run this script in MySQL to set up the entire database

-- 1. Create and use database
DROP DATABASE IF EXISTS library;
CREATE DATABASE library;
USE library;

-- 2. Create tables
CREATE TABLE books_available (
    bookid INT AUTO_INCREMENT PRIMARY KEY,
    book_name VARCHAR(255) NOT NULL,
    author_name VARCHAR(255) NOT NULL,
    year_of_publication INT,
    genre VARCHAR(100),
    availability INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    full_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    admin_level ENUM('librarian', 'superadmin') DEFAULT 'librarian',
    created_by VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE books_borrowed (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bookid INT NOT NULL,
    book_name VARCHAR(255) NOT NULL,
    author_name VARCHAR(255) NOT NULL,
    year_of_publication INT,
    genre VARCHAR(100),
    count INT DEFAULT 1,
    user VARCHAR(50) NOT NULL,
    borrowed_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    due_date DATE,
    FOREIGN KEY (bookid) REFERENCES books_available(bookid) ON DELETE CASCADE
);

CREATE TABLE borrowed_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    bookid INT NOT NULL,
    book_name VARCHAR(255) NOT NULL,
    author_name VARCHAR(255) NOT NULL,
    year_of_publication INT,
    genre VARCHAR(100),
    count INT DEFAULT 1,
    user VARCHAR(50) NOT NULL,
    borrowed_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    returned_date TIMESTAMP NULL,
    status ENUM('borrowed', 'returned') DEFAULT 'borrowed',
    FOREIGN KEY (bookid) REFERENCES books_available(bookid) ON DELETE CASCADE
);

-- 3. Insert default data
INSERT INTO admins (username, password, admin_level, created_by) 
VALUES 
('superadmin', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'superadmin', 'system'),
('librarian', '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918', 'librarian', 'superadmin');

INSERT INTO books_available (book_name, author_name, year_of_publication, genre, availability) VALUES
('To Kill a Mockingbird', 'Harper Lee', 1960, 'Fiction', 5),
('1984', 'George Orwell', 1949, 'Dystopian', 3),
('The Great Gatsby', 'F. Scott Fitzgerald', 1925, 'Classic', 4),
('Pride and Prejudice', 'Jane Austen', 1813, 'Romance', 6),
('The Catcher in the Rye', 'J.D. Salinger', 1951, 'Fiction', 2),
('Harry Potter and the Sorcerer''s Stone', 'J.K. Rowling', 1997, 'Fantasy', 8),
('The Hobbit', 'J.R.R. Tolkien', 1937, 'Fantasy', 3),
('The Da Vinci Code', 'Dan Brown', 2003, 'Mystery', 7),
('The Alchemist', 'Paulo Coelho', 1988, 'Philosophical Fiction', 5),
('Thinking, Fast and Slow', 'Daniel Kahneman', 2011, 'Psychology', 4);

INSERT INTO students (username, password, email, full_name) 
VALUES ('student1', '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4', 'student1@example.com', 'John Doe');

-- 4. Create indexes
CREATE INDEX idx_books_genre ON books_available(genre);
CREATE INDEX idx_books_author ON books_available(author_name);
CREATE INDEX idx_books_name ON books_available(book_name);
CREATE INDEX idx_borrowed_user ON books_borrowed(user);
CREATE INDEX idx_borrowed_book ON books_borrowed(bookid);
CREATE INDEX idx_history_user ON borrowed_history(user);
CREATE INDEX idx_history_book ON borrowed_history(bookid);
CREATE INDEX idx_history_status ON borrowed_history(status);
CREATE INDEX idx_students_username ON students(username);
CREATE INDEX idx_admins_username ON admins(username);

-- 5. Create views
CREATE VIEW book_statistics AS
SELECT 
    b.bookid,
    b.book_name,
    b.author_name,
    b.availability,
    COUNT(DISTINCT bh.user) as total_borrowers,
    COALESCE(SUM(bh.count), 0) as total_borrowed
FROM books_available b
LEFT JOIN borrowed_history bh ON b.bookid = bh.bookid
GROUP BY b.bookid, b.book_name, b.author_name, b.availability;

CREATE VIEW user_activity AS
SELECT 
    s.username,
    s.full_name,
    s.email,
    COUNT(DISTINCT bh.id) as total_borrowings,
    COUNT(DISTINCT CASE WHEN bh.status = 'borrowed' THEN bh.id END) as current_borrowings,
    MIN(bh.borrowed_date) as first_borrowed,
    MAX(bh.borrowed_date) as last_borrowed
FROM students s
LEFT JOIN borrowed_history bh ON s.username = bh.user
GROUP BY s.username, s.full_name, s.email;

CREATE VIEW overdue_books AS
SELECT 
    bb.*,
    DATEDIFF(CURDATE(), bb.due_date) as days_overdue
FROM books_borrowed bb
WHERE bb.due_date < CURDATE();

-- Show success message
SELECT '✅ Database setup completed successfully!' as message;
SELECT 'Default credentials:' as info;
SELECT 'Admin: superadmin / admin123' as credentials;
SELECT 'Student: student1 / 1234' as credentials;
