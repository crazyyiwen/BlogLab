use BlogDB

create database BlogDB;

create table ApplicationUser(
	ApplicationUserId int not null identity(1,1),
	Username varchar(20) not null,
	NormalizedUsername varchar(20) not null,
	Email varchar(30) not null,
	NormalizedEmail varchar(30) not null,
	Fullname varchar(30) null,
	PasswordHash nvarchar(MAX) not null,
	primary key(ApplicationUserId)
)

create index [IX_ApplicationUser_NormalizedUsername] on [dbo].[ApplicationUser] ([NormalizedUsername])
create index [IX_ApplicationUser_NormalizedEmail] on [dbo].[ApplicationUser] ([NormalizedEmail])

select * from ApplicationUser
select Username from ApplicationUser


create table Photo(
	PhotoId int not null identity(1,1),
	ApplicationUserId int not null,
	PublicId varchar(50) not null,
	ImageUrl varchar(250) not null,
	[Description] varchar(30) not null,
	PublishDate datetime not null default GETDATE(),
	UpdateDate datetime not null default GETDATE(),
	primary key(PhotoId),
	foreign key(ApplicationUserId) references ApplicationUser(ApplicationUserId)
)


create table Blog(
	BlogId int not null identity(1,1),
	ApplicationUserId int not null,
	PhotoId int null,
	Title varchar(50) not null,
	content varchar(MAX) not null,
	PublishDate datetime not null default GETDATE(),
	UpdateDate datetime not null default GETDATE(),
	ActiveInd bit not null default CONVERT(bit, 1),
	primary key(BlogId),
	foreign key(ApplicationUserId) references ApplicationUser(ApplicationUserId),
	foreign key(PhotoId) references Photo(PhotoId)
)

create table BlogComment(
	BlogCommentId int not null identity(1,1),
	ParentBlogCommentId int null,
	BlogId int not null,
	ApplicationUserId int not null,
	Content varchar(300) not null,
	PublishDate datetime not null default GETDATE(),
	UpdateDate datetime not null default GETDATE(),
	ActiveInd bit not null default CONVERT(bit,1),
	primary key(BlogCommentId),
	foreign key(BlogId) references Blog(BlogId),
	foreign key(ApplicationUserId) references ApplicationUser(ApplicationUserId)
)

create schema [aggregate]

create view [aggregate].[Blog]
as
	select
		t1.BlogId,
		t1.ApplicationUserId,
		t2.Username,
		t1.Title,
		t1.Content,
		t1.PhotoId,
		t1.PublishDate,
		t1.UpdateDate,
		t1.ActiveInd
	from
		dbo.Blog t1
	inner join
		dbo.ApplicationUser t2 on t1.ApplicationUserId = t2.ApplicationUserId

create view [aggregate].[BlogComment]
as
	select
		t1.BlogCommentId,
		t1.ParentBlogCommentId,
		t1.BlogId,
		t1.Content,
		t2.Username,
		t1.ApplicationUserId,
		t1.PublishDate,
		t1.UpdateDate,
		t1.ActiveInd
	from
		dbo.BlogComment t1
	inner join
		dbo.ApplicationUser t2 on t1.ApplicationUserId = t2.ApplicationUserId

create type [dbo].[AccountType] as table(
	[Username] varchar(20) not null,
	[NormalizedUsername] varchar(20) not null,
	[Email] varchar(30) not null,
	[NormalizedEmail] varchar(30) not null,
	[Fullname] varchar(30) null,
	[PasswordHash] nvarchar(MAX) not null
)


create procedure [dbo].[BlogComment_Upsert]
	@BlogComment BlogCommentType readonly,
	@ApplicationUserId int
as
	merge into [dbo].[BlogComment] target
	using(
		select
			[BlogCommentId],
			[ParentBlogCommentId],
			[BlogId],
			[Content],
			@ApplicationUserId [ApplicationUserId]
		from
			@BlogComment
	) as source
	on(
		target.[BlogCommentId] = source.[BlogCommentId] and Target.[ApplicationUserId] = source.[ApplicationUserId]
	)
	when matched then
		update set
			target.[Content] = source.[Content],
			target.[UpdateDate] = getdate()
	when not matched by target then
		insert(
			[ParentBlogCommentId],
			[BlogId],
			[ApplicationUserId],
			[Content]
		)
		values(
			source.[ParentBlogCommentId],
			source.[BlogId],
			source.[ApplicationUserId],
			source.[Content]
		);

	select cast(scope_identity() as int)


create procedure [dbo].[Photo_Delete]
	@PhotoId int
as
	delete from [dbo].[Photo] where [PhotoId] = @PhotoId




create procedure [dbo].[Photo_Get]
	@PhotoId int
as

	SELECT 
		t1.[PhotoId]
		,t1.[ApplicationUserId]
		,t1.[PublicId]
		,t1.[ImageUrl]
		,t1.[Description]
		,t1.[PublishDate]
		,t1.[UpdateDate]
	 FROM 
		[dbo].[Photo] t1
	where
		t1.[PhotoId] = @PhotoId
GO


create procedure [dbo].[Photo_GetByUserId]
		@ApplicationUserId int
as
	SELECT 
		t1.[PhotoId]
		,t1.[ApplicationUserId]
		,t1.[PublicId]
		,t1.[ImageUrl]
		,t1.[Description]
		,t1.[PublishDate]
		,t1.[UpdateDate]
	 FROM 
		[dbo].[Photo] t1
	where
		t1.[ApplicationUserId] = @ApplicationUserId
		


create procedure [dbo].[Photo_Insert]
	@Photo PhotoType readonly,
	@ApplicationUserId int
as
	insert into [dbo].[Photo]( 
		[ApplicationUserId]
		,[PublicId]
		,[ImageUrl]
		,[Description]
	)
	select
		@ApplicationUserId,
		[PublicId],
		[ImageUrl],
		[Description]
	from
		@Photo;

	select cast(SCOPE_IDENTITY() as int);
go