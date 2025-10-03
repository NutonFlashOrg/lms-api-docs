-- lms_tg_app.courses definition

CREATE TABLE `courses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(191) NOT NULL,
  `shortDesc` varchar(191) DEFAULT NULL,
  `accessScope` enum('ALL','CLIENTS_LIST') NOT NULL DEFAULT 'ALL',
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `courses_title_key` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.scales definition

CREATE TABLE `scales` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(191) NOT NULL,
  `name` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `scales_code_key` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.skills definition

CREATE TABLE `skills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) NOT NULL,
  `code` varchar(191) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `skills_code_key` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.storage_objects definition

CREATE TABLE `storage_objects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bucket` varchar(191) NOT NULL,
  `objectKey` varchar(191) NOT NULL,
  `contentType` varchar(191) DEFAULT NULL,
  `sizeBytes` int(11) DEFAULT NULL,
  `etag` varchar(191) DEFAULT NULL,
  `publicUrl` varchar(1024) NOT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `storage_objects_objectKey_key` (`objectKey`),
  KEY `storage_objects_bucket_idx` (`bucket`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.users definition

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `telegramId` bigint(20) DEFAULT NULL,
  `telegramUsername` varchar(64) NOT NULL,
  `displayName` varchar(191) DEFAULT NULL,
  `role` enum('ADMIN','CLIENT','MOP') NOT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_telegramUsername_key` (`telegramUsername`),
  UNIQUE KEY `users_telegramId_key` (`telegramId`),
  KEY `users_telegramUsername_idx` (`telegramUsername`),
  KEY `users_telegramId_idx` (`telegramId`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.clients definition

CREATE TABLE `clients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `level` enum('LEVEL_3','LEVEL_4') NOT NULL DEFAULT 'LEVEL_3',
  `inn` varchar(191) DEFAULT NULL,
  `activatedAt` datetime(3) DEFAULT NULL,
  `addedByAdminId` int(11) NOT NULL,
  `clientUserId` int(11) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `clients_clientUserId_key` (`clientUserId`),
  KEY `clients_addedByAdminId_fkey` (`addedByAdminId`),
  CONSTRAINT `clients_addedByAdminId_fkey` FOREIGN KEY (`addedByAdminId`) REFERENCES `users` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `clients_clientUserId_fkey` FOREIGN KEY (`clientUserId`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.course_client_access definition

CREATE TABLE `course_client_access` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `courseId` int(11) NOT NULL,
  `clientId` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `course_client_access_courseId_clientId_key` (`courseId`,`clientId`),
  KEY `course_client_access_clientId_idx` (`clientId`),
  CONSTRAINT `course_client_access_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `clients` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `course_client_access_courseId_fkey` FOREIGN KEY (`courseId`) REFERENCES `courses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.license_slots definition

CREATE TABLE `license_slots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `clientId` int(11) NOT NULL,
  `status` enum('ACTIVE','NOT_ACTIVE','EXPIRED') NOT NULL DEFAULT 'NOT_ACTIVE',
  `assignedMopUserId` int(11) DEFAULT NULL,
  `durationSeconds` int(11) NOT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `license_slots_clientId_idx` (`clientId`),
  KEY `license_slots_assignedMopUserId_fkey` (`assignedMopUserId`),
  CONSTRAINT `license_slots_assignedMopUserId_fkey` FOREIGN KEY (`assignedMopUserId`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `license_slots_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `clients` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.modules definition

CREATE TABLE `modules` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `courseId` int(11) NOT NULL,
  `title` varchar(191) NOT NULL,
  `shortDesc` varchar(191) DEFAULT NULL,
  `testVariant` enum('NONE','QUIZ') NOT NULL DEFAULT 'NONE',
  `unlockRule` enum('ALL','AFTER_PREV_MODULE','LEVEL_3','LEVEL_4') NOT NULL DEFAULT 'ALL',
  `orderIndex` int(11) NOT NULL DEFAULT 0,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `modules_courseId_idx` (`courseId`),
  CONSTRAINT `modules_courseId_fkey` FOREIGN KEY (`courseId`) REFERENCES `courses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.mop_profiles definition

CREATE TABLE `mop_profiles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `repScore` int(11) NOT NULL DEFAULT 0,
  `level` enum('LEVEL_3','LEVEL_4') NOT NULL DEFAULT 'LEVEL_3',
  `mopUserId` int(11) NOT NULL,
  `clientId` int(11) NOT NULL,
  `currentSlotId` int(11) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mop_profiles_mopUserId_key` (`mopUserId`),
  KEY `mop_profiles_clientId_idx` (`clientId`),
  KEY `mop_profiles_currentSlotId_fkey` (`currentSlotId`),
  CONSTRAINT `mop_profiles_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `clients` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `mop_profiles_currentSlotId_fkey` FOREIGN KEY (`currentSlotId`) REFERENCES `license_slots` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `mop_profiles_mopUserId_fkey` FOREIGN KEY (`mopUserId`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.refresh_tokens definition

CREATE TABLE `refresh_tokens` (
  `jti` varchar(191) NOT NULL,
  `userId` int(11) NOT NULL,
  `tokenHash` varchar(191) NOT NULL,
  `expiresAt` datetime(3) NOT NULL,
  `revokedAt` datetime(3) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  PRIMARY KEY (`jti`),
  KEY `refresh_tokens_userId_idx` (`userId`),
  CONSTRAINT `refresh_tokens_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.scale_options definition

CREATE TABLE `scale_options` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `scaleId` int(11) NOT NULL,
  `label` varchar(191) NOT NULL,
  `value` int(11) NOT NULL,
  `ord` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `scale_options_scaleId_ord_key` (`scaleId`,`ord`),
  CONSTRAINT `scale_options_scaleId_fkey` FOREIGN KEY (`scaleId`) REFERENCES `scales` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.scenarios definition

CREATE TABLE `scenarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(191) NOT NULL,
  `practiceType` enum('WITH_CASE','WITHOUT_CASE','MINI') NOT NULL,
  `updatedAt` datetime(3) NOT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `createdByUserId` int(11) NOT NULL,
  `version` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `scenarios_createdByUserId_fkey` (`createdByUserId`),
  CONSTRAINT `scenarios_createdByUserId_fkey` FOREIGN KEY (`createdByUserId`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.user_course_progress definition

CREATE TABLE `user_course_progress` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userId` int(11) NOT NULL,
  `courseId` int(11) NOT NULL,
  `completedLessons` int(11) NOT NULL DEFAULT 0,
  `completedQuizzes` int(11) NOT NULL DEFAULT 0,
  `progressPercent` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_course_progress_userId_courseId_key` (`userId`,`courseId`),
  KEY `user_course_progress_courseId_idx` (`courseId`),
  CONSTRAINT `user_course_progress_courseId_fkey` FOREIGN KEY (`courseId`) REFERENCES `courses` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `user_course_progress_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.user_course_statuses definition

CREATE TABLE `user_course_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userId` int(11) NOT NULL,
  `courseId` int(11) NOT NULL,
  `completedAt` datetime(3) NOT NULL,
  `passed` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_course_statuses_userId_courseId_key` (`userId`,`courseId`),
  KEY `user_course_statuses_courseId_idx` (`courseId`),
  CONSTRAINT `user_course_statuses_courseId_fkey` FOREIGN KEY (`courseId`) REFERENCES `courses` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `user_course_statuses_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.user_module_statuses definition

CREATE TABLE `user_module_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userId` int(11) NOT NULL,
  `moduleId` int(11) NOT NULL,
  `completedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_module_statuses_userId_moduleId_key` (`userId`,`moduleId`),
  KEY `user_module_statuses_moduleId_idx` (`moduleId`),
  CONSTRAINT `user_module_statuses_moduleId_fkey` FOREIGN KEY (`moduleId`) REFERENCES `modules` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `user_module_statuses_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.user_skill_summaries definition

CREATE TABLE `user_skill_summaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userId` int(11) NOT NULL,
  `skillId` int(11) NOT NULL,
  `posCount` int(11) NOT NULL DEFAULT 0,
  `negCount` int(11) NOT NULL DEFAULT 0,
  `status` enum('YES','NO','HALF') NOT NULL DEFAULT 'HALF',
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_skill_summaries_userId_skillId_key` (`userId`,`skillId`),
  KEY `user_skill_summaries_skillId_idx` (`skillId`),
  CONSTRAINT `user_skill_summaries_skillId_fkey` FOREIGN KEY (`skillId`) REFERENCES `skills` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `user_skill_summaries_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.cases definition

CREATE TABLE `cases` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(191) NOT NULL,
  `situation` varchar(191) NOT NULL,
  `sellerLegend` varchar(191) NOT NULL,
  `buyerLegend` varchar(191) NOT NULL,
  `sellerTask` varchar(191) NOT NULL,
  `buyerTask` varchar(191) NOT NULL,
  `recommendedSellerLevel` enum('LEVEL_3','LEVEL_4') NOT NULL DEFAULT 'LEVEL_3',
  `scenarioId` int(11) NOT NULL,
  `createdByUserId` int(11) NOT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `cases_scenarioId_fkey` (`scenarioId`),
  KEY `cases_createdByUserId_fkey` (`createdByUserId`),
  CONSTRAINT `cases_createdByUserId_fkey` FOREIGN KEY (`createdByUserId`) REFERENCES `users` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `cases_scenarioId_fkey` FOREIGN KEY (`scenarioId`) REFERENCES `scenarios` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.lessons definition

CREATE TABLE `lessons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `moduleId` int(11) NOT NULL,
  `title` varchar(191) NOT NULL,
  `shortDesc` varchar(191) DEFAULT NULL,
  `orderIndex` int(11) NOT NULL DEFAULT 0,
  `contentJson` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`contentJson`)),
  PRIMARY KEY (`id`),
  KEY `lessons_moduleId_idx` (`moduleId`),
  CONSTRAINT `lessons_moduleId_fkey` FOREIGN KEY (`moduleId`) REFERENCES `modules` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.practices definition

CREATE TABLE `practices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(191) NOT NULL,
  `scenarioId` int(11) NOT NULL,
  `caseId` int(11) DEFAULT NULL,
  `practiceType` enum('WITH_CASE','WITHOUT_CASE','MINI') NOT NULL,
  `createdByUserId` int(11) NOT NULL,
  `createdByRole` varchar(191) NOT NULL,
  `startAt` datetime(3) NOT NULL,
  `status` enum('DRAFT','PUBLISHED','SCHEDULED','IN_PROGRESS','AWAITING_EVAL','COMPLETED','CANCELED') NOT NULL DEFAULT 'DRAFT',
  `zoomLink` varchar(191) NOT NULL,
  `autoCancelAt` datetime(3) NOT NULL,
  `sellerUserId` int(11) DEFAULT NULL,
  `buyerUserId` int(11) DEFAULT NULL,
  `moderatorUserId` int(11) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  `scenarioVersion` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `practices_autoCancelAt_idx` (`autoCancelAt`),
  KEY `practices_scenarioId_caseId_idx` (`scenarioId`,`caseId`),
  KEY `practices_caseId_fkey` (`caseId`),
  KEY `practices_sellerUserId_fkey` (`sellerUserId`),
  KEY `practices_buyerUserId_fkey` (`buyerUserId`),
  KEY `practices_moderatorUserId_fkey` (`moderatorUserId`),
  CONSTRAINT `practices_buyerUserId_fkey` FOREIGN KEY (`buyerUserId`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `practices_caseId_fkey` FOREIGN KEY (`caseId`) REFERENCES `cases` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `practices_moderatorUserId_fkey` FOREIGN KEY (`moderatorUserId`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `practices_scenarioId_fkey` FOREIGN KEY (`scenarioId`) REFERENCES `scenarios` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `practices_sellerUserId_fkey` FOREIGN KEY (`sellerUserId`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.quizzes definition

CREATE TABLE `quizzes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `lessonId` int(11) DEFAULT NULL,
  `passThresholdPercent` int(11) NOT NULL DEFAULT 75,
  PRIMARY KEY (`id`),
  KEY `quizzes_lessonId_idx` (`lessonId`),
  CONSTRAINT `quizzes_lessonId_fkey` FOREIGN KEY (`lessonId`) REFERENCES `lessons` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.rep_events definition

CREATE TABLE `rep_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userId` int(11) NOT NULL,
  `practiceId` int(11) DEFAULT NULL,
  `delta` int(11) NOT NULL,
  `reasonCode` varchar(191) NOT NULL,
  `comment` varchar(191) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  PRIMARY KEY (`id`),
  KEY `rep_events_userId_idx` (`userId`),
  KEY `rep_events_practiceId_idx` (`practiceId`),
  CONSTRAINT `rep_events_practiceId_fkey` FOREIGN KEY (`practiceId`) REFERENCES `practices` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `rep_events_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.scenario_forms definition

CREATE TABLE `scenario_forms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `scenarioId` int(11) NOT NULL,
  `role` enum('SELLER','BUYER','MODERATOR') NOT NULL,
  `title` varchar(191) DEFAULT NULL,
  `descr` varchar(191) DEFAULT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `scenario_forms_scenarioId_role_key` (`scenarioId`,`role`),
  CONSTRAINT `scenario_forms_scenarioId_fkey` FOREIGN KEY (`scenarioId`) REFERENCES `scenarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.user_lesson_statuses definition

CREATE TABLE `user_lesson_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userId` int(11) NOT NULL,
  `lessonId` int(11) NOT NULL,
  `completedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_lesson_statuses_userId_lessonId_key` (`userId`,`lessonId`),
  KEY `user_lesson_statuses_lessonId_idx` (`lessonId`),
  CONSTRAINT `user_lesson_statuses_lessonId_fkey` FOREIGN KEY (`lessonId`) REFERENCES `lessons` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `user_lesson_statuses_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.user_skill_events definition

CREATE TABLE `user_skill_events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userId` int(11) NOT NULL,
  `skillId` int(11) NOT NULL,
  `practiceId` int(11) NOT NULL,
  `result` enum('POSITIVE','NEGATIVE','NEUTRAL') NOT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `negAnswers` int(11) NOT NULL DEFAULT 0,
  `neuAnswers` int(11) NOT NULL DEFAULT 0,
  `posAnswers` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_skill_events_userId_skillId_practiceId_key` (`userId`,`skillId`,`practiceId`),
  KEY `user_skill_events_skillId_idx` (`skillId`),
  KEY `user_skill_events_practiceId_idx` (`practiceId`),
  CONSTRAINT `user_skill_events_practiceId_fkey` FOREIGN KEY (`practiceId`) REFERENCES `practices` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `user_skill_events_skillId_fkey` FOREIGN KEY (`skillId`) REFERENCES `skills` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `user_skill_events_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.evaluation_submissions definition

CREATE TABLE `evaluation_submissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `practiceId` int(11) NOT NULL,
  `evaluatorUserId` int(11) NOT NULL,
  `evaluatedUserId` int(11) NOT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `updatedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `evaluation_submissions_practiceId_evaluatorUserId_evaluatedU_key` (`practiceId`,`evaluatorUserId`,`evaluatedUserId`),
  KEY `evaluation_submissions_evaluatorUserId_idx` (`evaluatorUserId`),
  KEY `evaluation_submissions_evaluatedUserId_idx` (`evaluatedUserId`),
  CONSTRAINT `evaluation_submissions_evaluatedUserId_fkey` FOREIGN KEY (`evaluatedUserId`) REFERENCES `users` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `evaluation_submissions_evaluatorUserId_fkey` FOREIGN KEY (`evaluatorUserId`) REFERENCES `users` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `evaluation_submissions_practiceId_fkey` FOREIGN KEY (`practiceId`) REFERENCES `practices` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.evaluation_tasks definition

CREATE TABLE `evaluation_tasks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `practiceId` int(11) NOT NULL,
  `evaluatorUserId` int(11) NOT NULL,
  `evaluatedUserId` int(11) NOT NULL,
  `targetRole` enum('SELLER','BUYER','MODERATOR') NOT NULL,
  `required` tinyint(1) NOT NULL DEFAULT 1,
  `status` enum('PENDING','SUBMITTED') NOT NULL DEFAULT 'PENDING',
  `deadlineAt` datetime(3) NOT NULL,
  `submittedAt` datetime(3) DEFAULT NULL,
  `overdueAt` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `evaluation_tasks_practiceId_evaluatorUserId_evaluatedUserId_key` (`practiceId`,`evaluatorUserId`,`evaluatedUserId`),
  KEY `evaluation_tasks_evaluatorUserId_idx` (`evaluatorUserId`),
  KEY `evaluation_tasks_evaluatedUserId_idx` (`evaluatedUserId`),
  KEY `evaluation_tasks_overdueAt_idx` (`overdueAt`),
  CONSTRAINT `evaluation_tasks_evaluatedUserId_fkey` FOREIGN KEY (`evaluatedUserId`) REFERENCES `users` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `evaluation_tasks_evaluatorUserId_fkey` FOREIGN KEY (`evaluatorUserId`) REFERENCES `users` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `evaluation_tasks_practiceId_fkey` FOREIGN KEY (`practiceId`) REFERENCES `practices` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.participant_eval_summaries definition

CREATE TABLE `participant_eval_summaries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `practiceId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `positivePercent` int(11) NOT NULL,
  `isPositive` tinyint(1) NOT NULL,
  `computedAt` datetime(3) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `participant_eval_summaries_practiceId_userId_key` (`practiceId`,`userId`),
  KEY `participant_eval_summaries_userId_idx` (`userId`),
  CONSTRAINT `participant_eval_summaries_practiceId_fkey` FOREIGN KEY (`practiceId`) REFERENCES `practices` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `participant_eval_summaries_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.practice_observers definition

CREATE TABLE `practice_observers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `practiceId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `joinedAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `practice_observers_practiceId_userId_key` (`practiceId`,`userId`),
  KEY `practice_observers_userId_idx` (`userId`),
  CONSTRAINT `practice_observers_practiceId_fkey` FOREIGN KEY (`practiceId`) REFERENCES `practices` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `practice_observers_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.practice_results definition

CREATE TABLE `practice_results` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `practiceId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `role` varchar(191) NOT NULL,
  `score` int(11) NOT NULL,
  `isGood` tinyint(1) NOT NULL,
  `createdAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `practice_results_practiceId_userId_key` (`practiceId`,`userId`),
  KEY `practice_results_userId_idx` (`userId`),
  KEY `practice_results_practiceId_idx` (`practiceId`),
  CONSTRAINT `practice_results_practiceId_fkey` FOREIGN KEY (`practiceId`) REFERENCES `practices` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `practice_results_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.practice_skills definition

CREATE TABLE `practice_skills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `practiceId` int(11) NOT NULL,
  `skillId` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `practice_skills_practiceId_skillId_key` (`practiceId`,`skillId`),
  KEY `practice_skills_skillId_idx` (`skillId`),
  CONSTRAINT `practice_skills_practiceId_fkey` FOREIGN KEY (`practiceId`) REFERENCES `practices` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `practice_skills_skillId_fkey` FOREIGN KEY (`skillId`) REFERENCES `skills` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.quiz_attempts definition

CREATE TABLE `quiz_attempts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `quizId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `startedAt` datetime(3) NOT NULL DEFAULT current_timestamp(3),
  `finishedAt` datetime(3) DEFAULT NULL,
  `scorePercent` int(11) NOT NULL DEFAULT 0,
  `passed` tinyint(1) NOT NULL DEFAULT 0,
  `shuffleSeed` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `quiz_attempts_quizId_idx` (`quizId`),
  KEY `quiz_attempts_userId_idx` (`userId`),
  CONSTRAINT `quiz_attempts_quizId_fkey` FOREIGN KEY (`quizId`) REFERENCES `quizzes` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `quiz_attempts_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `users` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.quiz_questions definition

CREATE TABLE `quiz_questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `quizId` int(11) NOT NULL,
  `text` varchar(191) NOT NULL,
  `order` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `quiz_questions_quizId_idx` (`quizId`),
  CONSTRAINT `quiz_questions_quizId_fkey` FOREIGN KEY (`quizId`) REFERENCES `quizzes` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.scenario_form_blocks definition

CREATE TABLE `scenario_form_blocks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `formId` int(11) NOT NULL,
  `type` enum('TEXT','QA','SCALE') NOT NULL,
  `title` varchar(191) NOT NULL,
  `helpText` varchar(191) DEFAULT NULL,
  `required` tinyint(1) NOT NULL DEFAULT 1,
  `position` int(11) NOT NULL,
  `skillId` int(11) DEFAULT NULL,
  `scaleId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `scenario_form_blocks_formId_position_idx` (`formId`,`position`),
  KEY `scenario_form_blocks_skillId_idx` (`skillId`),
  KEY `scenario_form_blocks_scaleId_fkey` (`scaleId`),
  CONSTRAINT `scenario_form_blocks_formId_fkey` FOREIGN KEY (`formId`) REFERENCES `scenario_forms` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `scenario_form_blocks_scaleId_fkey` FOREIGN KEY (`scaleId`) REFERENCES `scales` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `scenario_form_blocks_skillId_fkey` FOREIGN KEY (`skillId`) REFERENCES `skills` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.scenario_form_scale_items definition

CREATE TABLE `scenario_form_scale_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `blockId` int(11) NOT NULL,
  `title` varchar(191) NOT NULL,
  `position` int(11) NOT NULL,
  `skillId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `scenario_form_scale_items_blockId_position_key` (`blockId`,`position`),
  KEY `scenario_form_scale_items_skillId_idx` (`skillId`),
  CONSTRAINT `scenario_form_scale_items_blockId_fkey` FOREIGN KEY (`blockId`) REFERENCES `scenario_form_blocks` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `scenario_form_scale_items_skillId_fkey` FOREIGN KEY (`skillId`) REFERENCES `skills` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.evaluation_answers definition

CREATE TABLE `evaluation_answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `submissionId` int(11) NOT NULL,
  `blockId` int(11) NOT NULL,
  `scaleItemId` int(11) DEFAULT NULL,
  `selectedOptionId` int(11) DEFAULT NULL,
  `textAnswer` varchar(191) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `evaluation_answers_submissionId_blockId_scaleItemId_key` (`submissionId`,`blockId`,`scaleItemId`),
  KEY `evaluation_answers_blockId_fkey` (`blockId`),
  KEY `evaluation_answers_scaleItemId_fkey` (`scaleItemId`),
  KEY `evaluation_answers_selectedOptionId_fkey` (`selectedOptionId`),
  CONSTRAINT `evaluation_answers_blockId_fkey` FOREIGN KEY (`blockId`) REFERENCES `scenario_form_blocks` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `evaluation_answers_scaleItemId_fkey` FOREIGN KEY (`scaleItemId`) REFERENCES `scenario_form_scale_items` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `evaluation_answers_selectedOptionId_fkey` FOREIGN KEY (`selectedOptionId`) REFERENCES `scale_options` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `evaluation_answers_submissionId_fkey` FOREIGN KEY (`submissionId`) REFERENCES `evaluation_submissions` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lms_tg_app.quiz_answer_options definition

CREATE TABLE `quiz_answer_options` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `questionId` int(11) NOT NULL,
  `text` varchar(191) NOT NULL,
  `isCorrect` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `quiz_answer_options_questionId_idx` (`questionId`),
  CONSTRAINT `quiz_answer_options_questionId_fkey` FOREIGN KEY (`questionId`) REFERENCES `quiz_questions` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;