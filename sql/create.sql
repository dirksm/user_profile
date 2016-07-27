CREATE TABLE IF NOT EXISTS `users` (
  `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '',
  `username` VARCHAR(50) NOT NULL COMMENT '',
  `password` VARCHAR(255) NOT NULL COMMENT '',
  `new_password_key` VARCHAR(128) NULL DEFAULT NULL COMMENT 'Key for requesting new password',
  `new_password_requested` DATETIME NULL DEFAULT NULL COMMENT 'Datetime new password was created',
  `api_secret` VARCHAR(128) NULL DEFAULT NULL COMMENT 'Secret for API Token',
  `last_login` DATETIME DEFAULT NULL COMMENT '',
  `created` DATETIME DEFAULT NULL,
  `modified` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)  COMMENT 'User Table')
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;

DROP TRIGGER IF EXISTS `USERS_CREATE_TIMESTAMP`;
DELIMITER //
CREATE TRIGGER `USERS_CREATE_TIMESTAMP` BEFORE INSERT ON `users`
 FOR EACH ROW SET NEW.CREATED = NOW()
//
DELIMITER ;
DROP TRIGGER IF EXISTS `USERS_UPDATE_TIMESTAMP`;
DELIMITER //
CREATE TRIGGER `USERS_UPDATE_TIMESTAMP` BEFORE UPDATE ON `users`
 FOR EACH ROW SET NEW.modified = NOW()
//
DELIMITER ;


CREATE TABLE IF NOT EXISTS `user_profile` (
  `id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '',
  `user_id` INT(11) NOT NULL COMMENT '',
  `first_name` VARCHAR(50) NOT NULL COMMENT '',
  `last_name` VARCHAR(50) NOT NULL COMMENT '',
  `address` varchar(128) DEFAULT NULL,
  `city` varchar(64) DEFAULT NULL,
  `state` char(2) DEFAULT NULL,
  `zip` varchar(5) DEFAULT NULL,
  `work_phone` varchar(15) default NULL,
  `cell_phone` varchar(15) default NULL,
  `occupation` varchar(128) default NULL,
  `email` VARCHAR(100) NOT NULL COMMENT '',
  `about_me` TEXT CHARACTER SET 'utf8' COLLATE 'utf8_bin'  COMMENT '',
  `website` VARCHAR(255) CHARACTER SET 'utf8' COLLATE 'utf8_bin' NULL DEFAULT NULL COMMENT '',
  `created` DATETIME DEFAULT NULL,
  `modified` DATETIME DEFAULT NULL,
  PRIMARY KEY (`id`)  COMMENT '',
  INDEX `user_id` (`user_id` ASC)  COMMENT '',
  CONSTRAINT `user_profile_ibfk_1`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
)
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_bin;

DROP TRIGGER IF EXISTS `USER_PROFILE_CREATE_TIMESTAMP`;
DELIMITER //
CREATE TRIGGER `USER_PROFILE_CREATE_TIMESTAMP` BEFORE INSERT ON `user_profile`
 FOR EACH ROW SET NEW.CREATED = NOW()
//
DELIMITER ;
DROP TRIGGER IF EXISTS `USER_PROFILE_UPDATE_TIMESTAMP`;
DELIMITER //
CREATE TRIGGER `USER_PROFILE_UPDATE_TIMESTAMP` BEFORE UPDATE ON `user_profile`
 FOR EACH ROW SET NEW.modified = NOW()
//
DELIMITER ;

CREATE TABLE IF NOT EXISTS `user_types` (
  `user_type_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '',
  `title` VARCHAR(255) NOT NULL COMMENT '',
  `description` VARCHAR(255) NOT NULL COMMENT '',
  PRIMARY KEY (`user_type_id`)  COMMENT '')
ENGINE = InnoDB
AUTO_INCREMENT = 1
DEFAULT CHARACTER SET = utf8;

INSERT INTO `user_types` (`title`,`description`) VALUES
('admin', 'Administrator'),
('user','User');

CREATE TABLE IF NOT EXISTS `user_role_types` (
  `user` INT(11) NOT NULL COMMENT 'username',
  `role` INT(11) NOT NULL COMMENT 'role from user_types',
  PRIMARY KEY (`user`, `role`)  COMMENT '',
  CONSTRAINT `user_role_fk_1`
    FOREIGN KEY (`user`)
    REFERENCES `users` (`id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `user_role_fk_2`
    FOREIGN KEY (`role`)
    REFERENCES `user_types` (`user_type_id`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT
  )
ENGINE = InnoDB
COMMENT 'Maps user to user roles.';

INSERT INTO `users` (`username`, `password`) VALUES
('testadmin', '6ca13d52ca70c883e0f0bb101e425a89e8624de51db2d2392593af6a84118090');
INSERT INTO `users` (`username`, `password`) VALUES
('testuser', '6ca13d52ca70c883e0f0bb101e425a89e8624de51db2d2392593af6a84118090');

INSERT INTO `user_profile` (`user_id`, `first_name`, `last_name`, `email`) VALUES
((select id from `users` where username = 'testadmin'), 'Test', 'Admin', 'admin@email.net');
INSERT INTO `user_profile` (`user_id`, `first_name`, `last_name`, `email`) VALUES
((select id from `users` where username = 'testuser'), 'Test', 'User', 'user@email.net');


INSERT INTO `user_role_types` (`user`, `role`) VALUES
((select id from `users` where username = 'testadmin'), (select user_type_id from `user_types` where title = 'admin')),
((select id from `users` where username = 'testadmin'), (select user_type_id from `user_types` where title = 'user')),
((select id from `users` where username = 'testuser'), (select user_type_id from `user_types` where title = 'user'));

# Maps user to user roles.  Used for security realm
CREATE VIEW `user_roles` as 
(SELECT (select username from `users` u where u.id = ur.user) as username, (select title from `user_types` where user_type_id = ur.role) as role
FROM `user_role_types` ur);