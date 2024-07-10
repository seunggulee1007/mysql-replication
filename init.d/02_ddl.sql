create table board (
    `id` bigint NOT NULL  AUTO_INCREMENT              COMMENT '게시판 식별자',
    `title`   VARCHAR(188) NOT NULL                    COMMENT '게시판 제목',
    `content` TEXT                                     COMMENT '게시판 내용',
    `start_date` DATETIME NOT NULL                     COMMENT '게시글 시작 일자',
    `end_date` DATETIME NOT NULL                       COMMENT '게시글 종료 일자',
    `created` DATETIME NOT NULL                        COMMENT '등록일자',
    `updated` DATETIME NOT NULL                        COMMENT '수정일자',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;