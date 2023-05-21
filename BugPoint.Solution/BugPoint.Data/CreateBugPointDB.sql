USE [master]
GO

CREATE DATABASE [BugPointDB]
GO


IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [BugPointDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [BugPointDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [BugPointDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [BugPointDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [BugPointDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [BugPointDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [BugPointDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [BugPointDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [BugPointDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [BugPointDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [BugPointDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [BugPointDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [BugPointDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [BugPointDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [BugPointDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [BugPointDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [BugPointDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [BugPointDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [BugPointDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [BugPointDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [BugPointDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [BugPointDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [BugPointDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [BugPointDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [BugPointDB] SET  MULTI_USER 
GO
ALTER DATABASE [BugPointDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [BugPointDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [BugPointDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [BugPointDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
USE [BugPointDB]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_GetDaysAndTimeFromDate]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
    
CREATE FUNCTION [dbo].[fn_GetDaysAndTimeFromDate]    
    
(    
@StartDate DATEtime ,    
@EndDate DATEtime     
)    
RETURNS varchar(10)    
AS    
    
BEGIN    
    
DECLARE @Temp TABLE    
(    
Alldates DATE ,    
DayInWeek INT ,    
Rnk       INT     
)    
    
IF DATEDIFF(day,@StartDate , @EndDate ) = 0     
    
begin     
   declare @Output varchar(10)    
    
   SELECT @Output = CONVERT(varchar(5),DATEADD(minute,DATEDIFF(minute,@StartDate,@EndDate),0), 114) + ' ' + 'HH:MM'    
   RETURN CONVERT(varchar(5),DATEADD(minute,DATEDIFF(minute,@StartDate,@EndDate),0), 114) + ' ' + 'HH:MM'        
    
end     
    
ELSE    
    
begiN    
    
WITH ListDates(AllDates) AS    
(    SELECT @StartDate AS DATE    
    UNION ALL    
    SELECT DATEADD(DAY,1,AllDates)    
    FROM ListDates     
    WHERE AllDates < @EndDate)    
INSERT INTO @Temp(Alldates,DayInWeek,Rnk)    
SELECT AllDates,DATEPART(dw, AllDates) as DayInWeek,row_number() over(order by AllDates) rnk     
FROM ListDates    
where DATEPART(dw, AllDates) not in (1,7)    
    
    
declare @LoopCounter int,@MaxTableNo int ,@dateCalc Date , @PFlag Int = 0    
    
select @LoopCounter = min(rnk),@MaxTableNo = max (rnk) from @Temp    
    
while (@LoopCounter is not null and @LoopCounter <= @MaxTableNo)    
 Begin    
    
 select @dateCalc = AllDates from @Temp  where rnk  = @LoopCounter    
    
 if not exists ( select 1 from HolidayList where HolidayDate = @dateCalc )    
     
 BEGIN    
   SET @PFlag = @PFlag + 1    
 END    
    
   SET @LoopCounter=@LoopCounter + 1    
    
end    
    
  
return   convert(varchar(10),@PFlag) + ' ' +'Days'         
    
END    
    
return @Output    
    
END    
GO
/****** Object:  Table [dbo].[AssignedProject]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssignedProject](
	[AssignedProjectId] [int] IDENTITY(1,1) NOT NULL,
	[ProjectId] [int] NULL,
	[RoleId] [int] NULL,
	[Status] [bit] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
	[UserId] [int] NULL,
 CONSTRAINT [PK_AssignedProject] PRIMARY KEY CLUSTERED 
(
	[AssignedProjectId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AttachmentDetails]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AttachmentDetails](
	[AttachmentDetailsId] [bigint] IDENTITY(1,1) NOT NULL,
	[AttachmentBase64] [varchar](max) NULL,
	[BugId] [bigint] NULL,
	[AttachmentId] [bigint] NOT NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
 CONSTRAINT [PK_AttachmentDetails] PRIMARY KEY CLUSTERED 
(
	[AttachmentDetailsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Attachments]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Attachments](
	[AttachmentId] [bigint] IDENTITY(1,1) NOT NULL,
	[OriginalAttachmentName] [varchar](100) NULL,
	[GenerateAttachmentName] [varchar](100) NULL,
	[AttachmentType] [varchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
	[BugId] [bigint] NULL,
	[BucketName] [varchar](50) NULL,
	[DirectoryName] [varchar](50) NULL,
 CONSTRAINT [PK_Attachments] PRIMARY KEY CLUSTERED 
(
	[AttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Audit]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Audit](
	[AuditId] [bigint] IDENTITY(1,1) NOT NULL,
	[Area] [varchar](100) NULL,
	[ControllerName] [varchar](100) NULL,
	[ActionName] [varchar](100) NULL,
	[LoginStatus] [varchar](1) NULL,
	[LoggedInAt] [datetime] NULL,
	[LoggedOutAt] [datetime] NULL,
	[PageAccessed] [varchar](500) NULL,
	[IPAddress] [varchar](100) NULL,
	[SessionID] [varchar](100) NULL,
	[UserID] [bigint] NULL,
	[RoleId] [int] NULL,
	[LangId] [int] NULL,
	[IsFirstLogin] [bit] NULL,
	[CurrentDatetime] [datetime] NULL,
	[PortalToken] [varchar](100) NULL,
	[Logged] [bit] NULL,
 CONSTRAINT [PK_Audit] PRIMARY KEY CLUSTERED 
(
	[AuditId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Browsers]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Browsers](
	[BrowserId] [int] IDENTITY(1,1) NOT NULL,
	[BrowserName] [varchar](50) NULL,
	[Code] [int] NULL,
 CONSTRAINT [PK_Browsers] PRIMARY KEY CLUSTERED 
(
	[BrowserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BugDetails]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BugDetails](
	[BugDetailsId] [bigint] IDENTITY(1,1) NOT NULL,
	[BugSummaryId] [bigint] NULL,
	[Description] [nvarchar](999) NULL,
	[BugId] [bigint] NULL,
 CONSTRAINT [PK_BugDetails] PRIMARY KEY CLUSTERED 
(
	[BugDetailsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BugHistory]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BugHistory](
	[BugHistoryId] [bigint] IDENTITY(1,1) NOT NULL,
	[Message] [varchar](100) NULL,
	[ProcessDate] [datetime] NULL,
	[UserId] [bigint] NULL,
	[BugId] [bigint] NULL,
	[StatusId] [int] NULL,
	[PriorityId] [int] NULL,
	[AssignedTo] [bigint] NULL,
 CONSTRAINT [PK_BugHistory] PRIMARY KEY CLUSTERED 
(
	[BugHistoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BugReply]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BugReply](
	[BugReplyId] [bigint] IDENTITY(1,1) NOT NULL,
	[BugId] [bigint] NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedDateDisplay] [varchar](30) NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
	[DeleteStatus] [bit] NULL,
	[ModifiedOn] [datetime] NULL,
 CONSTRAINT [PK_BugReply] PRIMARY KEY CLUSTERED 
(
	[BugReplyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BugReplyDetails]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BugReplyDetails](
	[BugReplyDetailsId] [bigint] IDENTITY(1,1) NOT NULL,
	[BugId] [bigint] NULL,
	[Description] [nvarchar](2000) NULL,
	[BugReplyId] [bigint] NULL,
 CONSTRAINT [PK_BugReplyDetails] PRIMARY KEY CLUSTERED 
(
	[BugReplyDetailsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BugsIdentity]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BugsIdentity](
	[BugAutoId] [bigint] IDENTITY(1,1) NOT NULL,
	[BugIdentityId] [bigint] NULL,
 CONSTRAINT [PK_BugsIdentity] PRIMARY KEY CLUSTERED 
(
	[BugAutoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BugSummary]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BugSummary](
	[BugSummaryId] [bigint] IDENTITY(1,1) NOT NULL,
	[Summary] [nvarchar](100) NULL,
	[ProjectId] [int] NULL,
	[ProjectComponentId] [int] NULL,
	[SeverityId] [int] NULL,
	[PriorityId] [int] NULL,
	[VersionId] [int] NULL,
	[OperatingSystemId] [int] NULL,
	[HardwareId] [int] NULL,
	[BrowserId] [int] NULL,
	[WebFrameworkId] [int] NULL,
	[TestedOnId] [int] NULL,
	[BugTypeId] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
	[Urls] [varchar](500) NULL,
	[BugId] [bigint] NULL,
 CONSTRAINT [PK_BugSummary] PRIMARY KEY CLUSTERED 
(
	[BugSummaryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BugTracking]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BugTracking](
	[BugTrackingId] [bigint] IDENTITY(1,1) NOT NULL,
	[BugId] [bigint] NULL,
	[StatusId] [int] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
	[AssignedTo] [int] NULL,
	[ResolutionId] [int] NULL,
	[ClosedOn] [datetime] NULL,
 CONSTRAINT [PK_BugTracking] PRIMARY KEY CLUSTERED 
(
	[BugTrackingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BugTypes]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BugTypes](
	[BugTypeId] [int] IDENTITY(1,1) NOT NULL,
	[BugType] [varchar](50) NULL,
	[Code] [int] NULL,
 CONSTRAINT [PK_BugTypes] PRIMARY KEY CLUSTERED 
(
	[BugTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Category]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Category](
	[CategoryId] [smallint] IDENTITY(1,1) NOT NULL,
	[CategoryName] [varchar](50) NULL,
	[Status] [bit] NULL,
	[CreateDate] [datetime] NULL,
	[UserId] [bigint] NULL,
	[Code] [varchar](4) NULL,
	[CategoryDescription] [varchar](50) NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[CategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DesignationMaster]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DesignationMaster](
	[DesignationId] [int] IDENTITY(1,1) NOT NULL,
	[Designation] [varchar](50) NULL,
	[Status] [bit] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
 CONSTRAINT [PK_DesignationMaster] PRIMARY KEY CLUSTERED 
(
	[DesignationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ELMAH_Error]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ELMAH_Error](
	[ErrorId] [uniqueidentifier] NOT NULL,
	[Application] [nvarchar](60) NOT NULL,
	[Host] [nvarchar](50) NOT NULL,
	[Type] [nvarchar](100) NOT NULL,
	[Source] [nvarchar](60) NOT NULL,
	[Message] [nvarchar](500) NOT NULL,
	[User] [nvarchar](50) NOT NULL,
	[StatusCode] [int] NOT NULL,
	[TimeUtc] [datetime] NOT NULL,
	[Sequence] [int] IDENTITY(1,1) NOT NULL,
	[AllXml] [nvarchar](max) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmailLogs]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmailLogs](
	[EmailLogId] [bigint] IDENTITY(1,1) NOT NULL,
	[EmailId] [varchar](50) NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[TriggeredEvent] [varchar](50) NULL,
 CONSTRAINT [PK_EmailLogs] PRIMARY KEY CLUSTERED 
(
	[EmailLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FogotPasswordVerification]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FogotPasswordVerification](
	[FogotPasswordVerificationId] [bigint] IDENTITY(1,1) NOT NULL,
	[EmailId] [varchar](100) NULL,
	[VerifiedDate] [datetime] NULL,
	[VerificationCode] [varchar](100) NULL,
	[CreateDate] [datetime] NULL,
	[Verified] [bit] NULL,
 CONSTRAINT [PK_FogotPasswordVerification] PRIMARY KEY CLUSTERED 
(
	[FogotPasswordVerificationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GeneralSettings]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GeneralSettings](
	[GeneralSettingsId] [int] IDENTITY(1,1) NOT NULL,
	[Email] [varchar](50) NULL,
	[Name] [varchar](50) NULL,
	[SupportEmailId] [varchar](50) NULL,
	[WebsiteTitle] [varchar](50) NULL,
	[WebsiteUrl] [varchar](50) NULL,
	[EnableEmailFeature] [bit] NULL,
	[EnableSmsFeature] [bit] NULL,
	[EnableSignatureFeature] [bit] NULL,
 CONSTRAINT [PK_GeneralSettings] PRIMARY KEY CLUSTERED 
(
	[GeneralSettingsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Hardware]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Hardware](
	[HardwareId] [int] IDENTITY(1,1) NOT NULL,
	[Hardware] [varchar](50) NULL,
	[Code] [int] NULL,
 CONSTRAINT [PK_Hardware] PRIMARY KEY CLUSTERED 
(
	[HardwareId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HolidayList]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HolidayList](
	[HolidayId] [smallint] IDENTITY(1,1) NOT NULL,
	[HolidayDate] [date] NULL,
	[CreatedDate] [datetime] NULL,
	[HolidayName] [varchar](50) NULL,
 CONSTRAINT [PK_HolidayList] PRIMARY KEY CLUSTERED 
(
	[HolidayId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MenuCategory]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MenuCategory](
	[MenuCategoryId] [int] IDENTITY(1,1) NOT NULL,
	[MenuCategoryName] [nvarchar](50) NULL,
	[RoleID] [int] NULL,
	[Status] [bit] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
	[SortingOrder] [int] NULL,
 CONSTRAINT [PK_MenuCategory] PRIMARY KEY CLUSTERED 
(
	[MenuCategoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MenuMaster]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MenuMaster](
	[MenuId] [int] IDENTITY(1,1) NOT NULL,
	[MenuName] [varchar](100) NULL,
	[ControllerName] [varchar](100) NULL,
	[ActionMethod] [varchar](100) NULL,
	[Status] [bit] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedOn] [datetime] NULL,
	[UserId] [bigint] NULL,
	[MenuCategoryId] [int] NULL,
	[RoleId] [int] NULL,
	[SortingOrder] [int] NULL,
	[Area] [varchar](100) NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
 CONSTRAINT [PK_MenuMaster] PRIMARY KEY CLUSTERED 
(
	[MenuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MovedBugsHistory]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MovedBugsHistory](
	[MovedbugId] [bigint] IDENTITY(1,1) NOT NULL,
	[BugId] [bigint] NULL,
	[FromUserId] [int] NULL,
	[ToUserId] [int] NULL,
	[ProjectId] [int] NULL,
	[CreatedBy] [int] NULL,
	[CreatedOn] [datetime] NULL,
 CONSTRAINT [PK_MovedBugsHistory] PRIMARY KEY CLUSTERED 
(
	[MovedbugId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NLog]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MachineName] [nvarchar](200) NULL,
	[Logged] [datetime] NOT NULL,
	[Level] [varchar](5) NOT NULL,
	[Message] [nvarchar](max) NOT NULL,
	[Logger] [nvarchar](300) NULL,
	[Properties] [nvarchar](max) NULL,
	[Callsite] [nvarchar](300) NULL,
	[Exception] [nvarchar](max) NULL,
 CONSTRAINT [PK_dbo.Log] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Notice]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notice](
	[NoticeId] [int] IDENTITY(1,1) NOT NULL,
	[NoticeTitle] [nvarchar](500) NULL,
	[NoticeStart] [datetime] NULL,
	[NoticeEnd] [datetime] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedOn] [datetime] NULL,
	[CreatedBy] [bigint] NULL,
	[ModifiedBy] [bigint] NULL,
	[Status] [bit] NULL,
 CONSTRAINT [PK_Notice] PRIMARY KEY CLUSTERED 
(
	[NoticeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NoticeDetails]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NoticeDetails](
	[NoticeDetailsId] [int] IDENTITY(1,1) NOT NULL,
	[NoticeBody] [varchar](max) NULL,
	[NoticeId] [int] NULL,
 CONSTRAINT [PK_NoticeDetails] PRIMARY KEY CLUSTERED 
(
	[NoticeDetailsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OperatingSystem]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OperatingSystem](
	[OperatingSystemId] [int] IDENTITY(1,1) NOT NULL,
	[OperatingSystemName] [varchar](50) NULL,
	[Code] [int] NULL,
 CONSTRAINT [PK_OperatingSystem] PRIMARY KEY CLUSTERED 
(
	[OperatingSystemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PasswordHistory]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PasswordHistory](
	[PasswordHistoryId] [bigint] IDENTITY(1,1) NOT NULL,
	[PasswordHash] [varchar](300) NULL,
	[CreatedDate] [datetime] NULL,
	[UserId] [int] NULL,
	[ProcessType] [char](1) NULL,
 CONSTRAINT [PK_PasswordHistory] PRIMARY KEY CLUSTERED 
(
	[PasswordHistoryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Priority]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Priority](
	[PriorityId] [int] IDENTITY(1,1) NOT NULL,
	[PriorityName] [varchar](50) NULL,
	[Code] [int] NULL,
 CONSTRAINT [PK_Priority] PRIMARY KEY CLUSTERED 
(
	[PriorityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProjectComponent]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProjectComponent](
	[ProjectComponentId] [bigint] IDENTITY(1,1) NOT NULL,
	[ProjectId] [int] NULL,
	[ComponentName] [varchar](100) NULL,
	[ComponentDescription] [varchar](100) NULL,
	[Status] [bit] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
	[AssignedTo] [int] NULL,
 CONSTRAINT [PK_Component] PRIMARY KEY CLUSTERED 
(
	[ProjectComponentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Projects]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Projects](
	[ProjectId] [int] IDENTITY(1,1) NOT NULL,
	[ProjectName] [varchar](50) NULL,
	[ProjectDescription] [varchar](100) NULL,
	[ModifiedOn] [datetime] NULL,
	[CreatedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
	[Status] [bit] NULL,
 CONSTRAINT [PK_Projects] PRIMARY KEY CLUSTERED 
(
	[ProjectId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RegisterVerification]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RegisterVerification](
	[RegisterVerificationId] [bigint] IDENTITY(1,1) NOT NULL,
	[GeneratedToken] [varchar](70) NULL,
	[GeneratedDate] [datetime] NULL,
	[VerificationStatus] [bit] NULL,
	[Status] [bit] NULL,
	[UserId] [bigint] NOT NULL,
	[VerificationDate] [datetime] NULL,
 CONSTRAINT [PK_RegisterVerificationToken] PRIMARY KEY CLUSTERED 
(
	[RegisterVerificationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReplyAttachment]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReplyAttachment](
	[ReplyAttachmentId] [bigint] IDENTITY(1,1) NOT NULL,
	[OriginalAttachmentName] [varchar](100) NULL,
	[AttachmentType] [varchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
	[BugId] [bigint] NULL,
	[BugReplyId] [bigint] NULL,
	[BucketName] [varchar](50) NULL,
	[DirectoryName] [varchar](50) NULL,
	[GenerateAttachmentName] [varchar](100) NULL,
 CONSTRAINT [PK_ReplyAttachment] PRIMARY KEY CLUSTERED 
(
	[ReplyAttachmentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ReplyAttachmentDetails]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReplyAttachmentDetails](
	[ReplyAttachmentDetailsId] [bigint] IDENTITY(1,1) NOT NULL,
	[AttachmentBase64] [varchar](max) NULL,
	[BugId] [bigint] NULL,
	[ReplyAttachmentId] [bigint] NOT NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
 CONSTRAINT [PK_ReplyAttachmentDetails] PRIMARY KEY CLUSTERED 
(
	[ReplyAttachmentDetailsId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ResetPasswordVerification]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ResetPasswordVerification](
	[ResetTokenId] [bigint] IDENTITY(1,1) NOT NULL,
	[UserId] [bigint] NULL,
	[GeneratedToken] [varchar](70) NULL,
	[GeneratedDate] [datetime] NULL,
	[Status] [bit] NULL,
	[VerificationStatus] [bit] NULL,
	[VerificationDate] [datetime] NULL,
 CONSTRAINT [PK_ResetPasswordVerification] PRIMARY KEY CLUSTERED 
(
	[ResetTokenId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Resolution]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Resolution](
	[ResolutionId] [int] IDENTITY(1,1) NOT NULL,
	[Resolution] [varchar](50) NULL,
	[Code] [int] NULL,
 CONSTRAINT [PK_Resolution] PRIMARY KEY CLUSTERED 
(
	[ResolutionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RoleMaster]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RoleMaster](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [varchar](50) NULL,
	[Status] [bit] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedOn] [datetime] NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
 CONSTRAINT [PK_RoleMaster] PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SavedAssignedRoles]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SavedAssignedRoles](
	[AssignedRoleId] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [int] NULL,
	[RoleId] [int] NULL,
	[CreateDate] [datetime] NULL,
	[Status] [bit] NULL,
 CONSTRAINT [PK_SavedAssignedRoles] PRIMARY KEY CLUSTERED 
(
	[AssignedRoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Severity]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Severity](
	[SeverityId] [int] IDENTITY(1,1) NOT NULL,
	[Severity] [varchar](50) NULL,
	[Code] [int] NULL,
 CONSTRAINT [PK_Severity] PRIMARY KEY CLUSTERED 
(
	[SeverityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SMTPEmailSettings]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SMTPEmailSettings](
	[SmtpProviderId] [int] IDENTITY(1,1) NOT NULL,
	[Host] [varchar](50) NULL,
	[Port] [varchar](50) NULL,
	[Timeout] [int] NULL,
	[SslProtocol] [varchar](1) NULL,
	[TlSProtocol] [varchar](1) NULL,
	[Username] [varchar](100) NULL,
	[Password] [varchar](100) NULL,
	[Status] [bit] NULL,
	[Name] [varchar](50) NULL,
	[UserId] [int] NULL,
	[IsDefault] [bit] NULL,
	[MailSender] [varchar](100) NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedOn] [datetime] NULL,
	[EmailTo] [varchar](100) NULL,
 CONSTRAINT [PK_SMTPEmailSending] PRIMARY KEY CLUSTERED 
(
	[SmtpProviderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Status]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Status](
	[StatusId] [int] IDENTITY(1,1) NOT NULL,
	[StatusName] [varchar](50) NULL,
	[Code] [int] NULL,
	[ViewReporter] [bit] NULL,
	[ViewUser] [bit] NULL,
 CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED 
(
	[StatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TestedEnvironment]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TestedEnvironment](
	[TestedOnId] [int] IDENTITY(1,1) NOT NULL,
	[TestedOn] [varchar](50) NULL,
	[Code] [int] NULL,
 CONSTRAINT [PK_TestedEnvironment] PRIMARY KEY CLUSTERED 
(
	[TestedOnId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserMaster]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserMaster](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](100) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[EmailId] [nvarchar](100) NULL,
	[MobileNo] [varchar](20) NULL,
	[Gender] [char](1) NULL,
	[Status] [bit] NULL,
	[IsFirstLogin] [bit] NULL,
	[CreatedOn] [datetime] NULL,
	[ModifiedOn] [datetime] NULL,
	[IsFirstLoginDate] [datetime] NULL,
	[PasswordHash] [varchar](64) NULL,
	[CreatedBy] [int] NULL,
	[ModifiedBy] [int] NULL,
	[DesignationId] [int] NULL,
 CONSTRAINT [PK_UserMaster] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Version]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Version](
	[VersionId] [int] IDENTITY(1,1) NOT NULL,
	[VersionName] [varchar](50) NULL,
	[Code] [int] NULL,
 CONSTRAINT [PK_Version] PRIMARY KEY CLUSTERED 
(
	[VersionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WebFrameworks]    Script Date: 28-05-2022 2.27.18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WebFrameworks](
	[WebFrameworkId] [int] IDENTITY(1,1) NOT NULL,
	[WebFramework] [varchar](50) NULL,
	[Code] [int] NULL,
 CONSTRAINT [PK_WebFrameworks] PRIMARY KEY CLUSTERED 
(
	[WebFrameworkId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Browsers] ON 

INSERT [dbo].[Browsers] ([BrowserId], [BrowserName], [Code]) VALUES (1, N'Google Chrome', 1)
INSERT [dbo].[Browsers] ([BrowserId], [BrowserName], [Code]) VALUES (2, N'Mozilla Firefox
', 2)
INSERT [dbo].[Browsers] ([BrowserId], [BrowserName], [Code]) VALUES (3, N'Apple Safari

', 3)
INSERT [dbo].[Browsers] ([BrowserId], [BrowserName], [Code]) VALUES (4, N'Opera', 4)
INSERT [dbo].[Browsers] ([BrowserId], [BrowserName], [Code]) VALUES (5, N'Microsoft Edge', 5)
INSERT [dbo].[Browsers] ([BrowserId], [BrowserName], [Code]) VALUES (6, N'Brave', 6)
INSERT [dbo].[Browsers] ([BrowserId], [BrowserName], [Code]) VALUES (7, N'Internet Explorer', 7)
INSERT [dbo].[Browsers] ([BrowserId], [BrowserName], [Code]) VALUES (8, N'Chromium', 8)
INSERT [dbo].[Browsers] ([BrowserId], [BrowserName], [Code]) VALUES (9, N'Vivaldi', 9)
INSERT [dbo].[Browsers] ([BrowserId], [BrowserName], [Code]) VALUES (10, N'SeaMonkey', 10)
INSERT [dbo].[Browsers] ([BrowserId], [BrowserName], [Code]) VALUES (11, N'Yandex', 11)
INSERT [dbo].[Browsers] ([BrowserId], [BrowserName], [Code]) VALUES (12, N'All', 12)
SET IDENTITY_INSERT [dbo].[Browsers] OFF
GO
SET IDENTITY_INSERT [dbo].[BugsIdentity] ON 

INSERT [dbo].[BugsIdentity] ([BugAutoId], [BugIdentityId]) VALUES (1, 0)
SET IDENTITY_INSERT [dbo].[BugsIdentity] OFF
GO
SET IDENTITY_INSERT [dbo].[BugTypes] ON 

INSERT [dbo].[BugTypes] ([BugTypeId], [BugType], [Code]) VALUES (1, N'Functional ', 1)
INSERT [dbo].[BugTypes] ([BugTypeId], [BugType], [Code]) VALUES (2, N'Syntax', 2)
INSERT [dbo].[BugTypes] ([BugTypeId], [BugType], [Code]) VALUES (3, N'Logic', 3)
INSERT [dbo].[BugTypes] ([BugTypeId], [BugType], [Code]) VALUES (4, N'Calculation', 4)
INSERT [dbo].[BugTypes] ([BugTypeId], [BugType], [Code]) VALUES (5, N'Unit-level', 5)
INSERT [dbo].[BugTypes] ([BugTypeId], [BugType], [Code]) VALUES (6, N'System-level integration', 6)
INSERT [dbo].[BugTypes] ([BugTypeId], [BugType], [Code]) VALUES (7, N'Out of bounds bugs', 7)
INSERT [dbo].[BugTypes] ([BugTypeId], [BugType], [Code]) VALUES (8, N'Performance', 8)
INSERT [dbo].[BugTypes] ([BugTypeId], [BugType], [Code]) VALUES (9, N'Usability', 9)
INSERT [dbo].[BugTypes] ([BugTypeId], [BugType], [Code]) VALUES (10, N'Security defects', 10)
INSERT [dbo].[BugTypes] ([BugTypeId], [BugType], [Code]) VALUES (11, N'Compatibility defects', 11)
INSERT [dbo].[BugTypes] ([BugTypeId], [BugType], [Code]) VALUES (12, N'Designing', 12)
SET IDENTITY_INSERT [dbo].[BugTypes] OFF
GO
SET IDENTITY_INSERT [dbo].[DesignationMaster] ON 

INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (1, N'Technical Lead', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (2, N'Sr Software Developer', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (3, N'Software Developer', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (4, N'UI Developer', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (5, N'SQL Developer', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (6, N'Project Manager', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (7, N'Tester', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (8, N'Developer Team Lead', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (9, N'UI Developer Team Lead', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (10, N'Tester Team Lead', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (11, N'Support User', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (12, N'Business analyst User', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (13, N'Support Team Lead', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (14, N'Consultant', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (15, N'Database Administrator
', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (16, N'Network engineers', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (17, N'Security Auditor', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (18, N'External User', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (19, N'Administrator', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (20, N'Development Support', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (21, N'Business analyst Lead', 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[DesignationMaster] ([DesignationId], [Designation], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (22, N'Chief Executive Officer (CEO)', NULL, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[DesignationMaster] OFF
GO
SET IDENTITY_INSERT [dbo].[Hardware] ON 

INSERT [dbo].[Hardware] ([HardwareId], [Hardware], [Code]) VALUES (1, N'All', 1)
INSERT [dbo].[Hardware] ([HardwareId], [Hardware], [Code]) VALUES (2, N'PC', 2)
INSERT [dbo].[Hardware] ([HardwareId], [Hardware], [Code]) VALUES (3, N'HP', 3)
INSERT [dbo].[Hardware] ([HardwareId], [Hardware], [Code]) VALUES (4, N'DELL', 4)
INSERT [dbo].[Hardware] ([HardwareId], [Hardware], [Code]) VALUES (5, N'MAC', 5)
INSERT [dbo].[Hardware] ([HardwareId], [Hardware], [Code]) VALUES (6, N'LINUX', 6)
INSERT [dbo].[Hardware] ([HardwareId], [Hardware], [Code]) VALUES (7, N'MOBILE', 7)
SET IDENTITY_INSERT [dbo].[Hardware] OFF
GO
SET IDENTITY_INSERT [dbo].[HolidayList] ON 

INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (1, CAST(N'2021-01-26' AS Date), CAST(N'2021-12-02T16:16:01.710' AS DateTime), N'Republic Day')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (2, CAST(N'2021-02-19' AS Date), CAST(N'2021-12-02T16:16:01.710' AS DateTime), N'Chhatrapati Shivaji Maharaj Jayanti')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (3, CAST(N'2021-03-11' AS Date), CAST(N'2021-12-02T16:16:01.713' AS DateTime), N'Mahashivratri')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (4, CAST(N'2021-03-29' AS Date), CAST(N'2021-12-02T16:16:01.713' AS DateTime), N'Holi (Second Day)')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (5, CAST(N'2021-04-02' AS Date), CAST(N'2021-12-02T16:16:01.713' AS DateTime), N'Good Friday')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (6, CAST(N'2021-04-13' AS Date), CAST(N'2021-12-02T16:16:01.717' AS DateTime), N'Gudhi Padwa')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (7, CAST(N'2021-04-14' AS Date), CAST(N'2021-12-02T16:16:01.717' AS DateTime), N'Dr.Babasaheb Ambedkar Jayanti')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (8, CAST(N'2021-04-21' AS Date), CAST(N'2021-12-02T16:16:01.717' AS DateTime), N'Ram Navmi')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (9, CAST(N'2021-04-25' AS Date), CAST(N'2021-12-02T16:16:01.717' AS DateTime), N'Mahavir Jayanti')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (10, CAST(N'2021-05-01' AS Date), CAST(N'2021-12-02T16:16:01.720' AS DateTime), N'Maharashtra Din')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (11, CAST(N'2021-05-13' AS Date), CAST(N'2021-12-02T16:16:01.720' AS DateTime), N'Ramzan-Id (Id-UL-Fitr) (Shawal-1)')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (12, CAST(N'2021-05-26' AS Date), CAST(N'2021-12-02T16:16:01.720' AS DateTime), N'Buddha Pournima')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (13, CAST(N'2021-07-21' AS Date), CAST(N'2021-12-02T16:16:01.723' AS DateTime), N'Bakri Id (Id-Uz-Zuha)')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (14, CAST(N'2021-08-15' AS Date), CAST(N'2021-12-02T16:16:01.723' AS DateTime), N'Independence Day')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (15, CAST(N'2021-08-16' AS Date), CAST(N'2021-12-02T16:16:01.723' AS DateTime), N'Parsi New Year (Shahenshahi)')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (16, CAST(N'2021-08-19' AS Date), CAST(N'2021-12-02T16:16:01.727' AS DateTime), N'Moharum')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (17, CAST(N'2021-09-10' AS Date), CAST(N'2021-12-02T16:16:01.727' AS DateTime), N'Ganesh Chaturthi')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (18, CAST(N'2021-10-02' AS Date), CAST(N'2021-12-02T16:16:01.727' AS DateTime), N'Mahatma Gandhi Jayanti')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (19, CAST(N'2021-10-15' AS Date), CAST(N'2021-12-02T16:16:01.727' AS DateTime), N'Dasara')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (20, CAST(N'2021-10-19' AS Date), CAST(N'2021-12-02T16:16:01.730' AS DateTime), N'Id-E-Milad')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (21, CAST(N'2021-11-04' AS Date), CAST(N'2021-12-02T16:16:01.730' AS DateTime), N'Diwali Amavasaya (Laxmi Pujan)')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (22, CAST(N'2021-11-05' AS Date), CAST(N'2021-12-02T16:16:01.730' AS DateTime), N'Diwali (Bali Pratipada)')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (23, CAST(N'2021-11-19' AS Date), CAST(N'2021-12-02T16:16:01.733' AS DateTime), N'Guru Nanak Jayanti')
INSERT [dbo].[HolidayList] ([HolidayId], [HolidayDate], [CreatedDate], [HolidayName]) VALUES (24, CAST(N'2021-12-25' AS Date), CAST(N'2021-12-02T16:16:01.733' AS DateTime), N'Christmas')
SET IDENTITY_INSERT [dbo].[HolidayList] OFF
GO
SET IDENTITY_INSERT [dbo].[MenuCategory] ON 

INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (1, N'Masters', 1, 1, CAST(N'2020-07-28T16:10:17.200' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (2, N'Users', 1, 1, CAST(N'2020-07-28T16:10:17.200' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (3, N'Manage', 1, 1, CAST(N'2020-07-28T16:10:17.200' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (4, N'Masters', 2, 1, CAST(N'2021-08-27T18:53:46.243' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (5, N'Masters', 6, 0, CAST(N'2021-08-30T18:32:12.210' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (6, N'Overview', 5, 1, CAST(N'2021-09-03T12:25:24.863' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (7, N'Overview', 6, 1, CAST(N'2021-09-12T21:42:45.227' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (8, N'Overview', 4, 1, CAST(N'2021-09-17T09:16:12.590' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (9, N'Overview', 7, 1, CAST(N'2021-09-25T16:33:00.670' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (10, N'Overview', 3, 1, CAST(N'2021-10-01T13:00:54.800' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (11, N'Manage Users', 2, 1, CAST(N'2021-10-16T17:22:31.037' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (12, N'Overview', 8, 1, CAST(N'2021-10-18T15:53:59.743' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (13, N'Reports', 7, 1, CAST(N'2021-10-29T13:23:12.500' AS DateTime), CAST(N'2021-10-29T13:23:12.500' AS DateTime), NULL, 1, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (14, N'Reports', 6, 1, CAST(N'2021-10-27T13:51:11.527' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (15, N'Reports', 3, 1, CAST(N'2021-10-29T13:23:27.480' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (16, N'Overview', 10, 1, CAST(N'2021-12-28T19:22:49.977' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (17, N'Overview', 9, 1, CAST(N'2021-12-28T19:22:55.493' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (18, N'Overview', 12, 1, CAST(N'2021-12-30T16:13:46.740' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (19, N'Overview', 11, 1, CAST(N'2021-12-30T16:13:51.973' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (20, N'Reports', 10, 1, CAST(N'2021-12-30T16:14:33.413' AS DateTime), NULL, 1, NULL, NULL)
INSERT [dbo].[MenuCategory] ([MenuCategoryId], [MenuCategoryName], [RoleID], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy], [SortingOrder]) VALUES (21, N'Reports', 12, 1, CAST(N'2021-12-30T16:14:38.877' AS DateTime), NULL, 1, NULL, NULL)
SET IDENTITY_INSERT [dbo].[MenuCategory] OFF
GO
SET IDENTITY_INSERT [dbo].[MenuMaster] ON 

INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (1, N'Create Menu', N'MenuMaster', N'Create', 1, CAST(N'2021-08-26T11:06:20.333' AS DateTime), NULL, 1, 1, 1, 2, N'Administration', 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (2, N'Create Category', N'MenuCategory', N'Create', 1, CAST(N'2021-08-26T11:07:55.447' AS DateTime), NULL, 1, 1, 1, 1, N'Administration', 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (3, N'Ordering Category', N'Ordering', N'MenuCategory', 1, CAST(N'2021-08-26T11:08:40.447' AS DateTime), NULL, 1, 1, 1, 3, N'Administration', 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (4, N'Create Users', N'User', N'Create', 1, CAST(N'2021-08-26T11:10:08.820' AS DateTime), NULL, 1, 2, 1, 4, N'Administration', 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (5, N'Ordering MainMenu', N'Ordering', N'MainMenu', 1, CAST(N'2021-08-26T11:10:38.837' AS DateTime), NULL, 1, 1, 1, 5, N'Administration', 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (6, N'All Users', N'User', N'Index', 1, CAST(N'2021-08-26T11:11:42.340' AS DateTime), NULL, 1, 2, 1, 6, N'Administration', 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (7, N'RoleMaster', N'RoleMaster', N'Create', 1, CAST(N'2021-08-26T11:24:43.240' AS DateTime), NULL, 1, 1, 1, 7, N'Administration', 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (8, N'Add Project', N'Project', N'Create', 1, CAST(N'2021-08-27T18:54:31.387' AS DateTime), NULL, NULL, 4, 2, NULL, N'Administration', 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (9, N'Assign Project', N'AssignProject', N'Process', 1, CAST(N'2021-08-29T12:57:26.053' AS DateTime), NULL, NULL, 4, 2, NULL, N'Administration', 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (10, N'Add Component', N'Component', N'Add', 1, NULL, CAST(N'2021-09-25T16:37:28.947' AS DateTime), NULL, 7, 6, NULL, NULL, NULL, 1)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (11, N'Report Bug', N'Bug', N'Add', 1, CAST(N'2021-09-03T12:26:03.777' AS DateTime), NULL, NULL, 6, 5, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (12, N'MyBugs', N'MyBugList', N'Show', 1, CAST(N'2021-09-17T09:17:39.633' AS DateTime), NULL, NULL, 8, 4, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (13, N'My reported bugs', N'Buglist', N'Show', 1, NULL, CAST(N'2021-10-24T11:32:41.603' AS DateTime), NULL, 6, 5, NULL, NULL, NULL, 1)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (14, N'My reported bugs', N'BugList', N'AllReportedBugs', 1, NULL, CAST(N'2021-10-24T11:30:54.520' AS DateTime), NULL, 9, 7, NULL, NULL, NULL, 1)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (15, N'MyBugs', N'MyBugList', N'AllReportedBugs', 1, CAST(N'2021-09-25T16:37:12.437' AS DateTime), NULL, NULL, 7, 6, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (16, N'Report Bug', N'MyBug', N'Add', 1, CAST(N'2021-09-27T09:26:35.187' AS DateTime), NULL, NULL, 9, 7, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (17, N'All reported bugs', N'Manager', N'AllBugs', 1, CAST(N'2021-10-01T13:02:22.340' AS DateTime), NULL, NULL, 10, 3, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (18, N'Configure SMTP', N'GeneralConfiguration', N'SmtpSettings', 1, CAST(N'2021-10-02T12:59:03.010' AS DateTime), NULL, NULL, 3, 1, NULL, N'Administration', 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (19, N'Create User', N'User', N'Create', 1, CAST(N'2021-10-16T17:23:27.023' AS DateTime), NULL, NULL, 11, 2, NULL, N'Administration', 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (20, N'All Users', N'User', N'Index', 1, CAST(N'2021-10-16T17:24:21.060' AS DateTime), NULL, NULL, 11, 2, NULL, N'Administration', 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (21, N'My reported bugs', N'Buglist', N'Show', 1, NULL, CAST(N'2021-10-24T11:30:29.607' AS DateTime), NULL, 12, 8, NULL, NULL, NULL, 1)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (22, N'Report Bug', N'Bug', N'Add', 1, CAST(N'2021-10-18T15:55:56.180' AS DateTime), NULL, NULL, 12, 8, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (23, N'Bug Report', N'BugReport', N'DeveloperReport', 1, CAST(N'2021-10-27T13:51:55.340' AS DateTime), NULL, NULL, 14, 6, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (24, N'Bug Report	', N'BugReport', N'TesterReport', 1, NULL, CAST(N'2021-10-29T14:30:30.290' AS DateTime), NULL, 13, 7, NULL, NULL, NULL, 1)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (25, N'Bug Report	', N'BugReport', N'ManagerReport', 1, CAST(N'2021-10-29T13:25:39.870' AS DateTime), NULL, NULL, 15, 3, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (26, N'View Application Logs', N'ViewLogs', N'logs', 1, CAST(N'2021-11-01T15:57:49.007' AS DateTime), NULL, NULL, 3, 1, NULL, N'Administration', 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (27, N'Add', N'Testing ', N'Submit', 0, NULL, CAST(N'2021-11-08T10:48:52.857' AS DateTime), NULL, 6, 5, NULL, N'testing ', NULL, 1)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (28, N'MyTeam', N'Team', N'Members', 1, CAST(N'2021-11-17T17:07:46.570' AS DateTime), NULL, NULL, 8, 4, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (29, N'MyTeam', N'Team', N'Members', 1, CAST(N'2021-11-17T17:08:08.293' AS DateTime), NULL, NULL, 7, 6, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (30, N'MyTeam', N'Team', N'Members', 1, CAST(N'2021-11-17T17:09:17.997' AS DateTime), NULL, NULL, 9, 7, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (31, N'Bulk Action', N'MovingBugs', N'Process', 1, CAST(N'2021-11-17T17:10:26.963' AS DateTime), NULL, NULL, 1, 1, NULL, N'Administration', 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (32, N'MyTeam', N'Team', N'Members', 1, CAST(N'2021-11-17T19:09:26.987' AS DateTime), NULL, NULL, 6, 5, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (33, N'Recent Activities', N'BugList', N'ShowRecentActivities', 1, CAST(N'2021-11-22T17:55:57.580' AS DateTime), NULL, NULL, 6, 5, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (34, N'Recent Activities', N'BugList', N'AllRecentActivities', 1, CAST(N'2021-11-22T17:56:29.360' AS DateTime), NULL, NULL, 9, 7, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (35, N'Recent Activities', N'MyBugList', N'ShowRecentActivities', 1, CAST(N'2021-11-22T17:56:57.390' AS DateTime), NULL, NULL, 8, 4, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (36, N'Recent Activities', N'MyBugList', N'AllRecentActivities', 1, CAST(N'2021-11-22T17:57:23.717' AS DateTime), NULL, NULL, 7, 6, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (37, N'My reported bugs', N'BugList', N'AllReportedBugs', 1, CAST(N'2021-12-28T19:26:44.693' AS DateTime), NULL, NULL, 16, 10, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (38, N'Recent Activities', N'BugList', N'AllRecentActivities', 1, CAST(N'2021-12-28T19:49:08.817' AS DateTime), NULL, NULL, 16, 10, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (39, N'MyTeam', N'Team', N'Members', 1, CAST(N'2021-12-28T19:50:39.717' AS DateTime), NULL, NULL, 16, 10, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (40, N'Report Bug	', N'MyBug', N'Add', 1, CAST(N'2021-12-28T19:52:07.533' AS DateTime), NULL, NULL, 16, 10, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (41, N'My reported bugs', N'Buglist', N'Show', 1, CAST(N'2021-12-29T18:04:13.117' AS DateTime), NULL, NULL, 17, 9, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (42, N'Report Bug', N'Bug', N'Add', 1, CAST(N'2021-12-29T18:04:57.803' AS DateTime), NULL, NULL, 17, 9, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (43, N'MyTeam', N'Team', N'Members', 1, CAST(N'2021-12-29T18:05:32.020' AS DateTime), NULL, NULL, 17, 9, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (44, N'Recent Activities', N'BugList', N'ShowRecentActivities', 1, CAST(N'2021-12-29T18:06:05.227' AS DateTime), NULL, NULL, 17, 9, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (45, N'My reported bugs', N'BugList', N'AllReportedBugs', 1, CAST(N'2021-12-30T16:18:20.897' AS DateTime), NULL, NULL, 18, 12, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (46, N'Recent Activities', N'BugList', N'AllRecentActivities', 1, CAST(N'2021-12-30T16:18:45.503' AS DateTime), NULL, NULL, 18, 12, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (47, N'MyTeam', N'Team', N'Members', 1, CAST(N'2021-12-30T16:19:14.147' AS DateTime), NULL, NULL, 18, 12, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (48, N'Report Bug', N'MyBug', N'Add', 1, CAST(N'2021-12-30T16:19:38.480' AS DateTime), NULL, NULL, 18, 12, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (49, N'My reported bugs', N'Buglist', N'Show', 1, CAST(N'2021-12-30T16:20:07.903' AS DateTime), NULL, NULL, 19, 11, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (50, N'Report Bug', N'Bug', N'Add', 1, CAST(N'2021-12-30T16:20:36.650' AS DateTime), NULL, NULL, 19, 11, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (51, N'MyTeam', N'Team', N'Members', 1, CAST(N'2021-12-30T16:21:15.457' AS DateTime), NULL, NULL, 19, 11, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (52, N'Recent Activities', N'BugList', N'ShowRecentActivities', 1, CAST(N'2021-12-30T16:21:39.630' AS DateTime), NULL, NULL, 19, 11, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (53, N'Bug Report', N'BugReport', N'BusinessAnalystReport', 1, CAST(N'2021-12-30T16:23:23.947' AS DateTime), NULL, NULL, 21, 12, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (54, N'Bug Report	', N'BugReport', N'SupportReport', 1, CAST(N'2021-12-30T16:23:51.197' AS DateTime), NULL, NULL, 20, 10, NULL, NULL, 1, NULL)
INSERT [dbo].[MenuMaster] ([MenuId], [MenuName], [ControllerName], [ActionMethod], [Status], [CreatedOn], [ModifiedOn], [UserId], [MenuCategoryId], [RoleId], [SortingOrder], [Area], [CreatedBy], [ModifiedBy]) VALUES (55, N'Create Notice', N'Notice', N'Create', 1, CAST(N'2022-01-03T13:51:55.397' AS DateTime), NULL, NULL, 1, 1, NULL, N'Administration', 1, NULL)
SET IDENTITY_INSERT [dbo].[MenuMaster] OFF
GO
SET IDENTITY_INSERT [dbo].[OperatingSystem] ON 

INSERT [dbo].[OperatingSystem] ([OperatingSystemId], [OperatingSystemName], [Code]) VALUES (1, N'Microsoft Windows', 1)
INSERT [dbo].[OperatingSystem] ([OperatingSystemId], [OperatingSystemName], [Code]) VALUES (2, N'Apple macOS', 2)
INSERT [dbo].[OperatingSystem] ([OperatingSystemId], [OperatingSystemName], [Code]) VALUES (3, N'Ubuntu', 3)
INSERT [dbo].[OperatingSystem] ([OperatingSystemId], [OperatingSystemName], [Code]) VALUES (4, N'Chrome OS', 4)
INSERT [dbo].[OperatingSystem] ([OperatingSystemId], [OperatingSystemName], [Code]) VALUES (5, N'Elementary OS', 5)
INSERT [dbo].[OperatingSystem] ([OperatingSystemId], [OperatingSystemName], [Code]) VALUES (6, N'Fedora', 6)
INSERT [dbo].[OperatingSystem] ([OperatingSystemId], [OperatingSystemName], [Code]) VALUES (7, N'Linux', 7)
INSERT [dbo].[OperatingSystem] ([OperatingSystemId], [OperatingSystemName], [Code]) VALUES (8, N'Oracle Solaris', 8)
INSERT [dbo].[OperatingSystem] ([OperatingSystemId], [OperatingSystemName], [Code]) VALUES (9, N'Android', 9)
INSERT [dbo].[OperatingSystem] ([OperatingSystemId], [OperatingSystemName], [Code]) VALUES (10, N'iOS', 10)
INSERT [dbo].[OperatingSystem] ([OperatingSystemId], [OperatingSystemName], [Code]) VALUES (11, N'Windows phone OS', 11)
INSERT [dbo].[OperatingSystem] ([OperatingSystemId], [OperatingSystemName], [Code]) VALUES (12, N'Symbian', 12)
SET IDENTITY_INSERT [dbo].[OperatingSystem] OFF
GO
SET IDENTITY_INSERT [dbo].[Priority] ON 

INSERT [dbo].[Priority] ([PriorityId], [PriorityName], [Code]) VALUES (1, N'Urgent', 1)
INSERT [dbo].[Priority] ([PriorityId], [PriorityName], [Code]) VALUES (2, N'High', 2)
INSERT [dbo].[Priority] ([PriorityId], [PriorityName], [Code]) VALUES (3, N'Medium', 3)
INSERT [dbo].[Priority] ([PriorityId], [PriorityName], [Code]) VALUES (4, N'Low', 4)
SET IDENTITY_INSERT [dbo].[Priority] OFF
GO
SET IDENTITY_INSERT [dbo].[Resolution] ON 

INSERT [dbo].[Resolution] ([ResolutionId], [Resolution], [Code]) VALUES (1, N'Fixed', 1)
INSERT [dbo].[Resolution] ([ResolutionId], [Resolution], [Code]) VALUES (2, N'Invalid', 2)
INSERT [dbo].[Resolution] ([ResolutionId], [Resolution], [Code]) VALUES (3, N'Not Fixable', 3)
INSERT [dbo].[Resolution] ([ResolutionId], [Resolution], [Code]) VALUES (4, N'Duplicate', 4)
INSERT [dbo].[Resolution] ([ResolutionId], [Resolution], [Code]) VALUES (5, N'Works For Me', 5)
INSERT [dbo].[Resolution] ([ResolutionId], [Resolution], [Code]) VALUES (6, N'Incomplete', 6)
INSERT [dbo].[Resolution] ([ResolutionId], [Resolution], [Code]) VALUES (7, N'Remind', 7)
INSERT [dbo].[Resolution] ([ResolutionId], [Resolution], [Code]) VALUES (8, N'Unable to Duplicate', 8)
INSERT [dbo].[Resolution] ([ResolutionId], [Resolution], [Code]) VALUES (9, N'Later', 9)
SET IDENTITY_INSERT [dbo].[Resolution] OFF
GO
SET IDENTITY_INSERT [dbo].[RoleMaster] ON 

INSERT [dbo].[RoleMaster] ([RoleId], [RoleName], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (1, N'SuperAdmin', 1, CAST(N'2021-08-26T08:43:52.550' AS DateTime), NULL, 1, NULL)
INSERT [dbo].[RoleMaster] ([RoleId], [RoleName], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (2, N'Admin', 1, CAST(N'2021-08-26T08:43:52.550' AS DateTime), NULL, 1, NULL)
INSERT [dbo].[RoleMaster] ([RoleId], [RoleName], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (3, N'ProjectManager', 1, CAST(N'2021-08-26T08:43:52.550' AS DateTime), NULL, 1, NULL)
INSERT [dbo].[RoleMaster] ([RoleId], [RoleName], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (4, N'Developer', 1, CAST(N'2021-08-26T08:43:52.550' AS DateTime), NULL, 1, NULL)
INSERT [dbo].[RoleMaster] ([RoleId], [RoleName], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (5, N'Tester', 1, CAST(N'2021-08-26T08:43:52.550' AS DateTime), NULL, 1, NULL)
INSERT [dbo].[RoleMaster] ([RoleId], [RoleName], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (6, N'Developer Team Lead', 1, CAST(N'2021-08-26T08:43:52.550' AS DateTime), NULL, 1, NULL)
INSERT [dbo].[RoleMaster] ([RoleId], [RoleName], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (7, N'Tester Team Lead', 1, CAST(N'2021-08-26T08:43:52.550' AS DateTime), NULL, 1, NULL)
INSERT [dbo].[RoleMaster] ([RoleId], [RoleName], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (8, N'Reporter', 1, CAST(N'2021-10-18T15:36:11.580' AS DateTime), NULL, 1, NULL)
INSERT [dbo].[RoleMaster] ([RoleId], [RoleName], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (9, N'Support User', 1, CAST(N'2021-12-28T12:54:52.787' AS DateTime), NULL, 1, NULL)
INSERT [dbo].[RoleMaster] ([RoleId], [RoleName], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (10, N'Support Lead', 1, CAST(N'2021-12-28T12:55:02.923' AS DateTime), NULL, 1, NULL)
INSERT [dbo].[RoleMaster] ([RoleId], [RoleName], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (11, N'Business Analyst User', 1, CAST(N'2021-12-29T19:23:15.403' AS DateTime), NULL, 1, NULL)
INSERT [dbo].[RoleMaster] ([RoleId], [RoleName], [Status], [CreatedOn], [ModifiedOn], [CreatedBy], [ModifiedBy]) VALUES (12, N'Business Analyst Lead', 1, CAST(N'2021-12-29T19:23:24.260' AS DateTime), NULL, 1, NULL)
SET IDENTITY_INSERT [dbo].[RoleMaster] OFF
GO
SET IDENTITY_INSERT [dbo].[SavedAssignedRoles] ON 

INSERT [dbo].[SavedAssignedRoles] ([AssignedRoleId], [UserId], [RoleId], [CreateDate], [Status]) VALUES (1, 1, 1, CAST(N'2021-08-26T08:43:52.550' AS DateTime), 1)
INSERT [dbo].[SavedAssignedRoles] ([AssignedRoleId], [UserId], [RoleId], [CreateDate], [Status]) VALUES (2, 2, 2, CAST(N'2021-08-26T19:29:14.243' AS DateTime), 1)
INSERT [dbo].[SavedAssignedRoles] ([AssignedRoleId], [UserId], [RoleId], [CreateDate], [Status]) VALUES (3, 3, 5, CAST(N'2021-08-28T13:32:00.847' AS DateTime), 1)
INSERT [dbo].[SavedAssignedRoles] ([AssignedRoleId], [UserId], [RoleId], [CreateDate], [Status]) VALUES (4, 4, 6, CAST(N'2021-08-28T13:33:49.643' AS DateTime), 1)
INSERT [dbo].[SavedAssignedRoles] ([AssignedRoleId], [UserId], [RoleId], [CreateDate], [Status]) VALUES (5, 5, 7, CAST(N'2021-08-28T13:34:59.883' AS DateTime), 1)
INSERT [dbo].[SavedAssignedRoles] ([AssignedRoleId], [UserId], [RoleId], [CreateDate], [Status]) VALUES (6, 6, 4, CAST(N'2021-08-28T15:15:37.390' AS DateTime), 1)
INSERT [dbo].[SavedAssignedRoles] ([AssignedRoleId], [UserId], [RoleId], [CreateDate], [Status]) VALUES (7, 7, 3, CAST(N'2021-08-28T15:22:44.963' AS DateTime), 1)
SET IDENTITY_INSERT [dbo].[SavedAssignedRoles] OFF
GO
SET IDENTITY_INSERT [dbo].[Severity] ON 

INSERT [dbo].[Severity] ([SeverityId], [Severity], [Code]) VALUES (1, N'Blocker', 1)
INSERT [dbo].[Severity] ([SeverityId], [Severity], [Code]) VALUES (2, N'Critical', 2)
INSERT [dbo].[Severity] ([SeverityId], [Severity], [Code]) VALUES (3, N'Major', 3)
INSERT [dbo].[Severity] ([SeverityId], [Severity], [Code]) VALUES (4, N'Minor', 4)
INSERT [dbo].[Severity] ([SeverityId], [Severity], [Code]) VALUES (5, N'New Feature', 5)
INSERT [dbo].[Severity] ([SeverityId], [Severity], [Code]) VALUES (6, N'Normal', 6)
INSERT [dbo].[Severity] ([SeverityId], [Severity], [Code]) VALUES (7, N'Crash', 7)
SET IDENTITY_INSERT [dbo].[Severity] OFF
GO
SET IDENTITY_INSERT [dbo].[Status] ON 

INSERT [dbo].[Status] ([StatusId], [StatusName], [Code], [ViewReporter], [ViewUser]) VALUES (1, N'Open', 1, 0, 0)
INSERT [dbo].[Status] ([StatusId], [StatusName], [Code], [ViewReporter], [ViewUser]) VALUES (2, N'Confirmed', 2, 0, 1)
INSERT [dbo].[Status] ([StatusId], [StatusName], [Code], [ViewReporter], [ViewUser]) VALUES (3, N'InProgress', 3, 0, 1)
INSERT [dbo].[Status] ([StatusId], [StatusName], [Code], [ViewReporter], [ViewUser]) VALUES (4, N'ReOpened', 4, 1, 0)
INSERT [dbo].[Status] ([StatusId], [StatusName], [Code], [ViewReporter], [ViewUser]) VALUES (5, N'Resolved', 5, 0, 1)
INSERT [dbo].[Status] ([StatusId], [StatusName], [Code], [ViewReporter], [ViewUser]) VALUES (6, N'InTesting', 6, 1, 0)
INSERT [dbo].[Status] ([StatusId], [StatusName], [Code], [ViewReporter], [ViewUser]) VALUES (7, N'Closed', 7, 1, 0)
INSERT [dbo].[Status] ([StatusId], [StatusName], [Code], [ViewReporter], [ViewUser]) VALUES (8, N'OnHold', 8, 1, 1)
INSERT [dbo].[Status] ([StatusId], [StatusName], [Code], [ViewReporter], [ViewUser]) VALUES (9, N'Rejected', 9, 1, 0)
INSERT [dbo].[Status] ([StatusId], [StatusName], [Code], [ViewReporter], [ViewUser]) VALUES (10, N'Reply', 10, 1, 1)
INSERT [dbo].[Status] ([StatusId], [StatusName], [Code], [ViewReporter], [ViewUser]) VALUES (11, N'Duplicate', 11, 0, 1)
INSERT [dbo].[Status] ([StatusId], [StatusName], [Code], [ViewReporter], [ViewUser]) VALUES (12, N'UnConfirmed', 12, 0, 1)
SET IDENTITY_INSERT [dbo].[Status] OFF
GO
SET IDENTITY_INSERT [dbo].[TestedEnvironment] ON 

INSERT [dbo].[TestedEnvironment] ([TestedOnId], [TestedOn], [Code]) VALUES (1, N'Development', 1)
INSERT [dbo].[TestedEnvironment] ([TestedOnId], [TestedOn], [Code]) VALUES (2, N'Testing', 2)
INSERT [dbo].[TestedEnvironment] ([TestedOnId], [TestedOn], [Code]) VALUES (3, N'Staging', 3)
INSERT [dbo].[TestedEnvironment] ([TestedOnId], [TestedOn], [Code]) VALUES (4, N'Production', 4)
SET IDENTITY_INSERT [dbo].[TestedEnvironment] OFF
GO
SET IDENTITY_INSERT [dbo].[UserMaster] ON 

INSERT [dbo].[UserMaster] ([UserId], [UserName], [FirstName], [LastName], [EmailId], [MobileNo], [Gender], [Status], [IsFirstLogin], [CreatedOn], [ModifiedOn], [IsFirstLoginDate], [PasswordHash], [CreatedBy], [ModifiedBy], [DesignationId]) VALUES (1, N'SuperAdmin', N'SuperAdmin', N'SuperAdmin', N'saineshwarbageri@outlook.com', N'9879879877', N'M', 1, 0, CAST(N'2021-08-26T08:43:52.550' AS DateTime), CAST(N'2021-08-26T08:43:52.550' AS DateTime), CAST(N'2021-08-26T08:43:52.550' AS DateTime), N'f4915b1d2abce6a503cdfd8d035ee04b8493e79e83e8d9764b0892044836d668', 1, NULL, 19)
INSERT [dbo].[UserMaster] ([UserId], [UserName], [FirstName], [LastName], [EmailId], [MobileNo], [Gender], [Status], [IsFirstLogin], [CreatedOn], [ModifiedOn], [IsFirstLoginDate], [PasswordHash], [CreatedBy], [ModifiedBy], [DesignationId]) VALUES (2, N'AdminUser', N'Admin', N'Admin', N'saineshwarbageri@outlook.com', N'9875555888', N'M', 1, 0, CAST(N'2021-08-26T19:29:10.733' AS DateTime), NULL, CAST(N'2021-08-26T19:29:03.057' AS DateTime), N'f4915b1d2abce6a503cdfd8d035ee04b8493e79e83e8d9764b0892044836d668', 1, NULL, 19)
INSERT [dbo].[UserMaster] ([UserId], [UserName], [FirstName], [LastName], [EmailId], [MobileNo], [Gender], [Status], [IsFirstLogin], [CreatedOn], [ModifiedOn], [IsFirstLoginDate], [PasswordHash], [CreatedBy], [ModifiedBy], [DesignationId]) VALUES (3, N'Tester1', N'Tester1', N'Tester1', N'saineshwarbageri@outlook.com', N'8777777788', N'M', 0, 0, CAST(N'2021-08-28T13:32:00.380' AS DateTime), NULL, CAST(N'2021-08-28T13:32:00.150' AS DateTime), N'f4915b1d2abce6a503cdfd8d035ee04b8493e79e83e8d9764b0892044836d668', 1, NULL, 7)
INSERT [dbo].[UserMaster] ([UserId], [UserName], [FirstName], [LastName], [EmailId], [MobileNo], [Gender], [Status], [IsFirstLogin], [CreatedOn], [ModifiedOn], [IsFirstLoginDate], [PasswordHash], [CreatedBy], [ModifiedBy], [DesignationId]) VALUES (4, N'DevTeamLead', N'TeamLead', N'TeamLead', N'saineshwarbageri@outlook.com', N'8574475747', N'M', 0, 0, CAST(N'2021-08-28T13:33:49.233' AS DateTime), NULL, CAST(N'2021-08-28T13:33:49.030' AS DateTime), N'f4915b1d2abce6a503cdfd8d035ee04b8493e79e83e8d9764b0892044836d668', 1, NULL, 8)
INSERT [dbo].[UserMaster] ([UserId], [UserName], [FirstName], [LastName], [EmailId], [MobileNo], [Gender], [Status], [IsFirstLogin], [CreatedOn], [ModifiedOn], [IsFirstLoginDate], [PasswordHash], [CreatedBy], [ModifiedBy], [DesignationId]) VALUES (5, N'TesterTL', N'Tester TeamLead', N'Tester TeamLead', N'saineshwarbageri@outlook.com', N'8521478962', N'M', 0, 0, CAST(N'2021-08-28T13:34:59.477' AS DateTime), NULL, CAST(N'2021-08-28T13:34:59.263' AS DateTime), N'f4915b1d2abce6a503cdfd8d035ee04b8493e79e83e8d9764b0892044836d668', 1, NULL, 10)
INSERT [dbo].[UserMaster] ([UserId], [UserName], [FirstName], [LastName], [EmailId], [MobileNo], [Gender], [Status], [IsFirstLogin], [CreatedOn], [ModifiedOn], [IsFirstLoginDate], [PasswordHash], [CreatedBy], [ModifiedBy], [DesignationId]) VALUES (6, N'Developer1', N'Developer1', N'Developer1', N'saineshwarbageri@outlook.com', N'9875647888', N'M', 0, 0, CAST(N'2021-08-28T15:15:36.943' AS DateTime), CAST(N'2021-10-11T10:55:49.097' AS DateTime), CAST(N'2021-08-28T15:15:36.727' AS DateTime), N'f4915b1d2abce6a503cdfd8d035ee04b8493e79e83e8d9764b0892044836d668', 1, 9, 3)
INSERT [dbo].[UserMaster] ([UserId], [UserName], [FirstName], [LastName], [EmailId], [MobileNo], [Gender], [Status], [IsFirstLogin], [CreatedOn], [ModifiedOn], [IsFirstLoginDate], [PasswordHash], [CreatedBy], [ModifiedBy], [DesignationId]) VALUES (7, N'ProjectManager', N'ProjectManager', N'ProjectManager', N'saineshwarbageri@outlook.com', N'9855777777', N'M', 0, 0, CAST(N'2021-08-28T15:22:44.547' AS DateTime), NULL, CAST(N'2021-08-28T15:22:44.343' AS DateTime), N'f4915b1d2abce6a503cdfd8d035ee04b8493e79e83e8d9764b0892044836d668', 1, NULL, 6)
SET IDENTITY_INSERT [dbo].[UserMaster] OFF
GO

UPDATE [UserMaster]  SET   
PasswordHash = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92'
GO

UPDATE [UserMaster]  SET 
Status = 1
GO

SET IDENTITY_INSERT [dbo].[Version] ON 

INSERT [dbo].[Version] ([VersionId], [VersionName], [Code]) VALUES (1, N'UnSpecified', 1)
INSERT [dbo].[Version] ([VersionId], [VersionName], [Code]) VALUES (2, N'1.0', 2)
INSERT [dbo].[Version] ([VersionId], [VersionName], [Code]) VALUES (3, N'2.0', 3)
INSERT [dbo].[Version] ([VersionId], [VersionName], [Code]) VALUES (4, N'3.0', 4)
INSERT [dbo].[Version] ([VersionId], [VersionName], [Code]) VALUES (5, N'4.0', 5)
INSERT [dbo].[Version] ([VersionId], [VersionName], [Code]) VALUES (6, N'5.0', 6)
INSERT [dbo].[Version] ([VersionId], [VersionName], [Code]) VALUES (7, N'6.0', 7)
INSERT [dbo].[Version] ([VersionId], [VersionName], [Code]) VALUES (8, N'7.0', 8)
INSERT [dbo].[Version] ([VersionId], [VersionName], [Code]) VALUES (9, N'8.0', 9)
INSERT [dbo].[Version] ([VersionId], [VersionName], [Code]) VALUES (10, N'9.0', 10)
INSERT [dbo].[Version] ([VersionId], [VersionName], [Code]) VALUES (11, N'10.0', 11)
SET IDENTITY_INSERT [dbo].[Version] OFF
GO
SET IDENTITY_INSERT [dbo].[WebFrameworks] ON 

INSERT [dbo].[WebFrameworks] ([WebFrameworkId], [WebFramework], [Code]) VALUES (1, N'ASP.NET WebForms', 1)
INSERT [dbo].[WebFrameworks] ([WebFrameworkId], [WebFramework], [Code]) VALUES (2, N'ASP.NET MVC', 2)
INSERT [dbo].[WebFrameworks] ([WebFrameworkId], [WebFramework], [Code]) VALUES (3, N'ASP.NET Core', 3)
INSERT [dbo].[WebFrameworks] ([WebFrameworkId], [WebFramework], [Code]) VALUES (4, N'PHP', 4)
INSERT [dbo].[WebFrameworks] ([WebFrameworkId], [WebFramework], [Code]) VALUES (5, N'JSP', 5)
INSERT [dbo].[WebFrameworks] ([WebFrameworkId], [WebFramework], [Code]) VALUES (6, N'Ruby on Rails', 6)
INSERT [dbo].[WebFrameworks] ([WebFrameworkId], [WebFramework], [Code]) VALUES (7, N'Laravel', 7)
INSERT [dbo].[WebFrameworks] ([WebFrameworkId], [WebFramework], [Code]) VALUES (8, N'Angular', 8)
INSERT [dbo].[WebFrameworks] ([WebFrameworkId], [WebFramework], [Code]) VALUES (9, N'React', 9)
INSERT [dbo].[WebFrameworks] ([WebFrameworkId], [WebFramework], [Code]) VALUES (10, N'Vue', 10)
INSERT [dbo].[WebFrameworks] ([WebFrameworkId], [WebFramework], [Code]) VALUES (11, N'Ember', 11)
INSERT [dbo].[WebFrameworks] ([WebFrameworkId], [WebFramework], [Code]) VALUES (12, N'Backbone', 12)
INSERT [dbo].[WebFrameworks] ([WebFrameworkId], [WebFramework], [Code]) VALUES (13, N'Express', 13)
INSERT [dbo].[WebFrameworks] ([WebFrameworkId], [WebFramework], [Code]) VALUES (14, N'Django', 14)
INSERT [dbo].[WebFrameworks] ([WebFrameworkId], [WebFramework], [Code]) VALUES (15, N'Spring', 15)
INSERT [dbo].[WebFrameworks] ([WebFrameworkId], [WebFramework], [Code]) VALUES (16, N'Flask', 16)
SET IDENTITY_INSERT [dbo].[WebFrameworks] OFF
GO
/****** Object:  Index [IX_AssignedProject_ProjectId_UserId]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_AssignedProject_ProjectId_UserId] ON [dbo].[AssignedProject]
(
	[ProjectId] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_AttachmentDetails_BugId]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_AttachmentDetails_BugId] ON [dbo].[AttachmentDetails]
(
	[BugId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Attachments_BugId]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_Attachments_BugId] ON [dbo].[Attachments]
(
	[BugId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BugDetails_BugId]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_BugDetails_BugId] ON [dbo].[BugDetails]
(
	[BugId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BugHistory_BugId]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_BugHistory_BugId] ON [dbo].[BugHistory]
(
	[BugId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BugReply_BugId]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_BugReply_BugId] ON [dbo].[BugReply]
(
	[BugId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BugReplyDetails_BugId]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_BugReplyDetails_BugId] ON [dbo].[BugReplyDetails]
(
	[BugId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BugSummary_BugId]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_BugSummary_BugId] ON [dbo].[BugSummary]
(
	[BugId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BugSummary_ProjectId]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_BugSummary_ProjectId] ON [dbo].[BugSummary]
(
	[ProjectId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_BugTracking_BugId]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_BugTracking_BugId] ON [dbo].[BugTracking]
(
	[BugId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_ELMAH_Error]    Script Date: 28-05-2022 2.27.19 PM ******/
ALTER TABLE [dbo].[ELMAH_Error] ADD  CONSTRAINT [PK_ELMAH_Error] PRIMARY KEY NONCLUSTERED 
(
	[ErrorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ELMAH_Error_App_Time_Seq]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_ELMAH_Error_App_Time_Seq] ON [dbo].[ELMAH_Error]
(
	[Application] ASC,
	[TimeUtc] DESC,
	[Sequence] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ProjectComponent_ProjectId]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_ProjectComponent_ProjectId] ON [dbo].[ProjectComponent]
(
	[ProjectId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ReplyAttachment_BugId]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_ReplyAttachment_BugId] ON [dbo].[ReplyAttachment]
(
	[BugId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ReplyAttachmentDetails_BugId]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_ReplyAttachmentDetails_BugId] ON [dbo].[ReplyAttachmentDetails]
(
	[BugId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_SavedAssignedRoles_UserId]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_SavedAssignedRoles_UserId] ON [dbo].[SavedAssignedRoles]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Usermaster_EmailId]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_Usermaster_EmailId] ON [dbo].[UserMaster]
(
	[EmailId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Usermaster_UserName]    Script Date: 28-05-2022 2.27.19 PM ******/
CREATE NONCLUSTERED INDEX [IX_Usermaster_UserName] ON [dbo].[UserMaster]
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BugReply] ADD  CONSTRAINT [DF_BugReply_DeleteStatus]  DEFAULT ((0)) FOR [DeleteStatus]
GO
ALTER TABLE [dbo].[ELMAH_Error] ADD  CONSTRAINT [DF_ELMAH_Error_ErrorId]  DEFAULT (newid()) FOR [ErrorId]
GO
ALTER TABLE [dbo].[GeneralSettings] ADD  CONSTRAINT [DF_GeneralSettings_EnableEmailFeature]  DEFAULT ((0)) FOR [EnableEmailFeature]
GO
ALTER TABLE [dbo].[GeneralSettings] ADD  CONSTRAINT [DF_GeneralSettings_EnableSmsFeature]  DEFAULT ((0)) FOR [EnableSmsFeature]
GO
ALTER TABLE [dbo].[GeneralSettings] ADD  CONSTRAINT [DF_GeneralSettings_EnableSignatureFeature]  DEFAULT ((0)) FOR [EnableSignatureFeature]
GO
ALTER TABLE [dbo].[MenuMaster] ADD  CONSTRAINT [DF_MenuMaster_CreateDate]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[UserMaster] ADD  CONSTRAINT [DF_UserMaster_IsFirstLogin]  DEFAULT ((0)) FOR [IsFirstLogin]
GO
/****** Object:  StoredProcedure [dbo].[NLog_Procedure]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[NLog_Procedure] (  
  @machineName nvarchar(200),  
  @logged datetime,  
  @level varchar(5),  
  @message nvarchar(max),  
  @logger nvarchar(300),  
  @properties nvarchar(max),  
  @callsite nvarchar(300),  
  @exception nvarchar(max)  
) AS  
BEGIN  
  INSERT INTO [dbo].[NLog] (  
    [MachineName],  
    [Logged],  
    [Level],  
    [Message],  
    [Logger],  
    [Properties],  
    [Callsite],  
    [Exception]  
  ) VALUES (  
    @machineName,  
    @logged,  
    @level,  
    @message,  
    @logger,  
    @properties,  
    @callsite,  
    @exception  
  )  
  
  end  
GO
/****** Object:  StoredProcedure [dbo].[Usp_AddMovingBugsHistory]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_AddMovingBugsHistory]  
    @BugId BIGINT,  
    @FromUserId INT,  
    @ToUserId INT,  
    @ProjectId INT,  
    @CreatedBy INT,  
    @RoleId INT  
AS  
BEGIN  
  
    INSERT INTO [dbo].[MovedBugsHistory]  
    (  
        [BugId],  
        [FromUserId],  
        [ToUserId],  
        [ProjectId],  
        [CreatedBy],  
        [CreatedOn]  
    )  
    VALUES  
    (@BugId, @FromUserId, @ToUserId, @ProjectId, @CreatedBy, GETDATE());  
  
    IF (@RoleId = 4 OR @RoleId = 6)  
    BEGIN  
        UPDATE dbo.BugTracking  
        SET AssignedTo = @ToUserId,  
            ModifiedOn = GETDATE()  
        WHERE BugId = @BugId;  
    END;  
  
   IF (@RoleId = 5 OR @RoleId = 7 OR @RoleId = 8)  
    BEGIN  
        UPDATE dbo.BugTracking  
        SET CreatedBy = @ToUserId,  
            ModifiedOn = GETDATE()  
        WHERE BugId = @BugId;  
    END;  
  
  
END;  
GO
/****** Object:  StoredProcedure [dbo].[Usp_Bug_HistorybugRepliesbyBugId]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_Bug_HistorybugRepliesbyBugId]        
@BugId bigint        
as        
        
begin        
        
select br.BugId, br.BugReplyId, br.CreatedDateDisplay , brd.Description , Um.FirstName as RepliedUserName       
,br.CreatedOn   ,br.CreatedBy    
,case when RM.RoleId = 5 then 'Reporter' when RM.RoleId = 4 then 'Replier' ELSE 'Replier' end as EditOption  
,RM.RoleId  
 from BugReply br        
      
inner join BugReplyDetails brd on br.BugReplyId = brd.BugReplyId        
inner join UserMaster UM on br.CreatedBy = UM.UserId        
inner join SavedAssignedRoles SAR on Um.UserId = SAR.UserId        
inner join RoleMaster RM on RM.RoleId = SAR.RoleId        
where br.BugId = @BugId        
        
end  
GO
/****** Object:  StoredProcedure [dbo].[Usp_BugIdentity]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_BugIdentity]

as
begin

declare @maxvalue bigint
declare @runningvalue bigint
set @maxvalue = (SELECT MAX(BugIdentityId) FROM BugsIdentity)

if (@maxvalue =0)
begin
set @runningvalue = 1
end
else 
begin
set @runningvalue = @maxvalue +1
end

UPDATE BugsIdentity
SET BugIdentityId = @runningvalue

return @runningvalue

end


GO
/****** Object:  StoredProcedure [dbo].[Usp_BugListGrid]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_BugListGrid]                
@CreatedBy bigint,                
@ProjectId int = null,                
@PriorityId int= null,                
@SeverityId int= null,                
@StatusId int = null,                
@AssignedtoId int = null,       
@ProjectComponentId int = null,                
@page INT,                
@pageSize INT                
as                
begin                
                
                
DECLARE @SQLQuery AS NVARCHAR(max)                
set @SQLQuery = ''                
SET @SQLQuery = @SQLQuery + '                
SELECT * FROM                
(                 
                
select ROW_NUMBER() OVER (ORDER BY BS.BugId desc) as RowNum,                
BS.BugId ,                
BS.Summary ,                
P.ProjectName ,                
PC.ComponentName,                
pr.PriorityName,                
case when ISNULL(RS.ResolutionId,0) =0 then ''NA'' else rs.Resolution end as Resolution,                
s.Severity,                
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,                
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,                
UM.FirstName +'' ''+ SUBSTRING(UM.LastName, 1, 1)  as AssignedTo,               
ST.StatusName,              
ST.StatusId,        
CONVERT(varchar(10),bt.ClosedOn,126) as ClosedOn,
TE.TestedOn,
TE.TestedOnId
from BugSummary BS                
inner join BugTracking bt on BS.BugId = bt.BugId                
inner join Projects p on BS.ProjectId = p.ProjectId                
inner join Severity S on BS.SeverityId = S.SeverityId                
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                
inner join Priority pr on BS.PriorityId = pr.PriorityId                
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                
inner join UserMaster UM on Bt.AssignedTo = UM.UserId                 
inner join Status St on Bt.StatusId = St.StatusId  
inner join TestedEnvironment TE on BS.TestedOnId = TE.TestedOnId
where bt.CreatedBy = '''+ convert(VARCHAR(10),@CreatedBy) + ''''                
                
if(@ProjectId is not null and @ProjectId>0)                
 begin                
 SET @SQLQuery = @SQLQuery + '                 
  and  BS.ProjectId = ' + convert(VARCHAR(50),@ProjectId) + ' '                  
 end                 
                
if(@PriorityId is not null and @PriorityId>0)                
 begin                
 SET @SQLQuery = @SQLQuery + '                 
  and  BS.PriorityId = ' + convert(VARCHAR(50),@PriorityId) + ' '                  
 end                 
                
 if(@SeverityId is not null and @SeverityId>0)                
 begin                
 SET @SQLQuery = @SQLQuery + '                 
  and  BS.SeverityId = ' + convert(VARCHAR(50),@SeverityId) + ' '                  
 end                 
                
 if(@StatusId is not null and @StatusId>0)                
 begin                
 SET @SQLQuery = @SQLQuery + '                 
  and  Bt.StatusId = ' + convert(VARCHAR(50),@StatusId) + ' '                  
 end     
     
  if(@AssignedtoId is not null and @AssignedtoId>0)                
 begin                
 SET @SQLQuery = @SQLQuery + '                 
  and  Bt.AssignedTo = ' + convert(VARCHAR(50),@AssignedtoId) + ' '                  
 end         
                 
 if(@ProjectComponentId is not null and @ProjectComponentId>0)                
 begin                
 SET @SQLQuery = @SQLQuery + '                 
  and  BS.ProjectComponentId = ' + convert(VARCHAR(50),@ProjectComponentId) + ' '                  
 end                 
                 
SET @SQLQuery = @SQLQuery + '  ) A                
WHERE A.RowNum                
BETWEEN (((' + convert(VARCHAR(10),@page) + ' - 1) * ' + convert(VARCHAR(10),@pageSize) + ') + 1) AND (' + convert(VARCHAR(10),@page) + ' * ' + convert(VARCHAR(10),@pageSize) + ')                
ORDER BY A.RowNum;'                
                
print @SQLQuery                
EXEC (@SQLQuery)                
                
                
end     
GO
/****** Object:  StoredProcedure [dbo].[Usp_BugListGrid_LastSevenDays]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_BugListGrid_LastSevenDays]                    
@CreatedBy bigint,                                 
@page INT,                    
@pageSize INT                    
as                    
begin                    
                    
declare @lastweek datetime    
declare @now datetime    
set @now = getdate()    
set @lastweek = dateadd(day,-7,@now)    
    
DECLARE @SQLQuery AS NVARCHAR(max)                    
set @SQLQuery = ''                    
SET @SQLQuery = @SQLQuery + '                    
SELECT * FROM                    
(                     
                    
select ROW_NUMBER() OVER (ORDER BY isnull(bt.ModifiedOn,bt.CreatedOn) desc) as RowNum,                    
BS.BugId ,                    
BS.Summary ,                    
P.ProjectName ,                    
PC.ComponentName,                    
pr.PriorityName,                    
case when ISNULL(RS.ResolutionId,0) =0 then ''NA'' else rs.Resolution end as Resolution,                    
s.Severity,                    
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,                    
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,                    
UM.FirstName +'' ''+ SUBSTRING(UM.LastName, 1, 1)  as AssignedTo,                   
ST.StatusName,                  
ST.StatusId,            
CONVERT(varchar(10),bt.ClosedOn,126) as ClosedOn            
from BugSummary BS                    
inner join BugTracking bt on BS.BugId = bt.BugId                    
inner join Projects p on BS.ProjectId = p.ProjectId                    
inner join Severity S on BS.SeverityId = S.SeverityId                    
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                    
inner join Priority pr on BS.PriorityId = pr.PriorityId                    
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                    
inner join UserMaster UM on Bt.AssignedTo = UM.UserId                     
inner join Status St on Bt.StatusId = St.StatusId                     
where bt.CreatedBy = '''+ convert(VARCHAR(10),@CreatedBy) + ''''                    
  
SET @SQLQuery = @SQLQuery + 'and  convert(VARCHAR(10),isnull(bt.ModifiedOn,bt.CreatedOn),23) >=  '''+ convert(VARCHAR(10),@lastweek,23) + ''''               
                
SET @SQLQuery = @SQLQuery + '  ) A                    
WHERE A.RowNum                    
BETWEEN (((' + convert(VARCHAR(10),@page) + ' - 1) * ' + convert(VARCHAR(10),@pageSize) + ') + 1) AND (' + convert(VARCHAR(10),@page) + ' * ' + convert(VARCHAR(10),@pageSize) + ')                    
ORDER BY A.RowNum;'                    
                    
print @SQLQuery                    
EXEC (@SQLQuery)                    
                    
                    
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_BugListGridCount]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Proc [dbo].[Usp_BugListGridCount]    
@CreatedBy bigint,    
@ProjectId int = null,    
@PriorityId int= null,    
@SeverityId int= null,    
@StatusId int = null,
@AssignedtoId int = null,  
@ProjectComponentId int = null    
as    
begin    
    
    
DECLARE @SQLQuery AS NVARCHAR(max)    
set @SQLQuery = ''    
SET @SQLQuery = @SQLQuery + '    
    
select  count(1) as ctn    
from BugSummary BS    
inner join BugTracking bt on BS.BugId = bt.BugId    
inner join Projects p on BS.ProjectId = p.ProjectId    
inner join Severity S on BS.SeverityId = S.SeverityId    
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId    
inner join Priority pr on BS.PriorityId = pr.PriorityId    
left join Resolution RS on bt.ResolutionId = RS.ResolutionId    
inner join UserMaster UM on Bt.AssignedTo = UM.UserId     
inner join Status St on Bt.StatusId = St.StatusId     
where bt.CreatedBy = '''+ convert(VARCHAR(10),@CreatedBy) + ''''    
    
if(@ProjectId is not null and @ProjectId>0)    
 begin    
 SET @SQLQuery = @SQLQuery + '     
  and  BS.ProjectId = ' + convert(VARCHAR(50),@ProjectId) + ' '      
 end     
    
if(@PriorityId is not null and @PriorityId>0)    
 begin    
 SET @SQLQuery = @SQLQuery + '     
  and  BS.PriorityId = ' + convert(VARCHAR(50),@PriorityId) + ' '      
 end     
    
 if(@SeverityId is not null and @SeverityId>0)    
 begin    
 SET @SQLQuery = @SQLQuery + '     
  and  BS.SeverityId = ' + convert(VARCHAR(50),@SeverityId) + ' '      
 end     
    
 if(@StatusId is not null and @StatusId>0)    
 begin    
 SET @SQLQuery = @SQLQuery + '     
  and  Bt.StatusId = ' + convert(VARCHAR(50),@StatusId) + ' '      
 end     
    if(@AssignedtoId is not null and @AssignedtoId>0)            
 begin            
 SET @SQLQuery = @SQLQuery + '             
  and  Bt.AssignedTo = ' + convert(VARCHAR(50),@AssignedtoId) + ' '              
 end     
 if(@ProjectComponentId is not null and @ProjectComponentId>0)    
 begin    
 SET @SQLQuery = @SQLQuery + '     
  and  BS.ProjectComponentId = ' + convert(VARCHAR(50),@ProjectComponentId) + ' '      
 end     
     
SET @SQLQuery = @SQLQuery + ' '    
    
print @SQLQuery    
EXEC (@SQLQuery)    
    
    
end    
    
--- exec Usp_BugListGridCount 6,1,1,3,1,1,10
GO
/****** Object:  StoredProcedure [dbo].[Usp_BugListGridCount_LastSevenDays]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_BugListGridCount_LastSevenDays]          
@CreatedBy bigint              
as          
begin          
     
 declare @lastweek datetime    
declare @now datetime    
set @now = getdate()    
set @lastweek = dateadd(day,-7,@now)    
          
DECLARE @SQLQuery AS NVARCHAR(max)          
set @SQLQuery = ''          
SET @SQLQuery = @SQLQuery + '          
          
select  count(1) as ctn          
from BugSummary BS          
inner join BugTracking bt on BS.BugId = bt.BugId          
inner join Projects p on BS.ProjectId = p.ProjectId          
inner join Severity S on BS.SeverityId = S.SeverityId          
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId          
inner join Priority pr on BS.PriorityId = pr.PriorityId          
left join Resolution RS on bt.ResolutionId = RS.ResolutionId          
inner join UserMaster UM on Bt.AssignedTo = UM.UserId           
inner join Status St on Bt.StatusId = St.StatusId           
where bt.CreatedBy = '''+ convert(VARCHAR(10),@CreatedBy) + ''''          
     
         
SET @SQLQuery = @SQLQuery + 'and  convert(VARCHAR(10),isnull(bt.ModifiedOn,bt.CreatedOn),23) >=  '''+ convert(VARCHAR(10),@lastweek,23) + ''''            
    
     
           
SET @SQLQuery = @SQLQuery + ' '          
          
print @SQLQuery          
EXEC (@SQLQuery)          
          
          
end          
          
--- exec Usp_BugListGridCount_LastSevenDays 6,1,1,3,1,1,10
GO
/****** Object:  StoredProcedure [dbo].[Usp_BusinessAnalyst_GetStatusWiseBugCount_Reporter]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_BusinessAnalyst_GetStatusWiseBugCount_Reporter]      
  
@ProjectId int      
as      
      
begin      
declare @OpenCount          int      
declare @OpenValue          varchar(20)      
declare @ConfirmedCount   int      
declare @ConfirmedValue          varchar(20)      
declare @InProgressCount  int      
declare @InProgressValue          varchar(20)      
declare @ReOpenedCount   int      
declare @ReOpenedValue          varchar(20)      
declare @ResolvedCount   int      
declare @ResolvedValue          varchar(20)      
declare @InTestingCount   int      
declare @InTestingValue          varchar(20)      
declare @ClosedCount    int      
declare @ClosedValue          varchar(20)      
declare @OnHoldCount   int      
declare @OnHoldValue          varchar(20)      
declare @RejectedCount   int      
declare @RejectedValue          varchar(20)      
declare @ReplyCount    int      
declare @ReplyValue          varchar(20)      
declare @DuplicateCount   int      
declare @DuplicateValue          varchar(20)      
declare @UnConfirmedCount  int      
declare @UnConfirmedValue          varchar(20)      
      
      
SELECT @OpenCount = COUNT(1) , @OpenValue = 'Open'  FROM dbo.BugTracking bt          
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId          
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId        
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12))  AND bs.ProjectId =@ProjectId and s.StatusId = 1        
        
SELECT @ConfirmedCount = COUNT(1) , @ConfirmedValue ='Confirmed'   FROM dbo.BugTracking bt          
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId          
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId        
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12))  AND bs.ProjectId =@ProjectId and s.StatusId = 2       
       
SELECT @InProgressCount = COUNT(1) , @InProgressValue ='In-Progress'   FROM dbo.BugTracking bt          
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId          
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId        
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12))  AND bs.ProjectId =@ProjectId and s.StatusId = 3      
       
SELECT @ReOpenedCount =COUNT(1) ,@ReOpenedValue = 'Re-Opened'   FROM dbo.BugTracking bt          
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId          
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId        
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12))  AND bs.ProjectId =@ProjectId and s.StatusId = 4        
       
      
SELECT @ResolvedCount =COUNT(1) , @ResolvedValue ='Resolved'   FROM dbo.BugTracking bt          
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId          
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId        
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12))   AND bs.ProjectId =@ProjectId and s.StatusId = 5        
       
      
SELECT @InTestingCount=COUNT(1) , @InTestingValue='InTesting'   FROM dbo.BugTracking bt          
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId          
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId        
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12))   AND bs.ProjectId =@ProjectId and s.StatusId = 6        
       
      
SELECT @ClosedCount =COUNT(1) ,@ClosedValue = 'Closed'   FROM dbo.BugTracking bt          
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId          
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId        
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12))   AND bs.ProjectId =@ProjectId and s.StatusId = 7       
       
      
SELECT @OnHoldCount =COUNT(1) , @OnHoldValue='On-Hold'   FROM dbo.BugTracking bt          
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId          
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId        
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12))   AND bs.ProjectId =@ProjectId and s.StatusId = 8        
       
      
SELECT @RejectedCount = COUNT(1) , @RejectedValue ='Rejected'   FROM dbo.BugTracking bt          
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId          
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId        
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12))   AND bs.ProjectId =@ProjectId and s.StatusId = 9        
       
      
SELECT @ReplyCount =COUNT(1) , @ReplyValue = 'Reply'   FROM dbo.BugTracking bt          
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId          
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId        
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12))   AND bs.ProjectId =@ProjectId and s.StatusId =10        
       
      
SELECT @DuplicateCount =COUNT(1) , @DuplicateValue ='Duplicate'   FROM dbo.BugTracking bt          
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId          
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId        
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12))   AND bs.ProjectId =@ProjectId and s.StatusId = 11       
      
      
SELECT @UnConfirmedCount = COUNT(1) , @UnConfirmedValue = 'UnConfirmed'       
FROM dbo.BugTracking bt          
right JOIN dbo.Status s ON bt.StatusId =s.StatusId          
right JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId        
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12))   AND bs.ProjectId =@ProjectId and s.StatusId = 12        
      
      
select @OpenCount as OpenCount , @OpenValue as 'Open',            
 @ConfirmedCount  as ConfirmedCount, @ConfirmedValue as 'Confirmed'  ,       
 @InProgressCount as InProgress , @InProgressValue as 'InProgress',      
 @ReOpenedCount as ReOpenedCount ,@ReOpenedValue as 'ReOpened',      
 @ResolvedCount as ResolvedCount , @ResolvedValue as 'Resolved',      
 @InTestingCount as InTestingCount  , @InTestingValue as 'InTesting',      
 @ClosedCount as ClosedCount , @ClosedValue as 'Closed',      
 @OnHoldCount as OnHoldCount  , @OnHoldValue as 'OnHold',      
 @RejectedCount as RejectedCount , @RejectedValue as 'Rejected',      
 @ReplyCount as  ReplyCount  , @ReplyValue as  'Reply',      
 @DuplicateCount as DuplicateCount  , @DuplicateValue as 'Duplicate',      
 @UnConfirmedCount as UnConfirmedCount ,@UnConfirmedValue as 'UnConfirmed'      
      
      
      
End 
GO
/****** Object:  StoredProcedure [dbo].[Usp_BusinessAnalystBugListGrid_LastSevenDays]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Usp_BusinessAnalystBugListGrid_LastSevenDays 1,10,102

CREATE Proc [dbo].[Usp_BusinessAnalystBugListGrid_LastSevenDays]                                                
                                        
@page INT,                                            
@pageSize INT,                               
@UserId INT                                
as                                            
begin                                            
                      
 declare @lastweek datetime                    
declare @now datetime                    
set @now = getdate()                    
set @lastweek = dateadd(day,-7,@now)                                           
                                            
DECLARE @SQLQuery AS NVARCHAR(max)                                            
set @SQLQuery = ''                                            
SET @SQLQuery = @SQLQuery + '                                            
SELECT * FROM                                            
(                                             
                                            
select ROW_NUMBER() OVER (ORDER BY BS.BugId desc) as RowNum,                                            
BS.BugId ,                                            
BS.Summary ,                                            
P.ProjectName ,                                            
PC.ComponentName,                                            
pr.PriorityName,                                            
case when ISNULL(RS.ResolutionId,0) =0 then ''NA'' else rs.Resolution end as Resolution,                                            
s.Severity,                                            
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,                                            
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,                                            
UM.FirstName +'' ''+ SUBSTRING(UM.LastName, 1, 1) as AssignedTo,                                  
UMR.FirstName +'' ''+ SUBSTRING(UMR.LastName, 1, 1) as Reportedby,                                   
ST.StatusName,                                          
ST.StatusId,                              
CONVERT(varchar(10),bt.ClosedOn,126) as ClosedOn                              
from BugSummary BS                                            
inner join BugTracking bt on BS.BugId = bt.BugId                                            
inner join Projects p on BS.ProjectId = p.ProjectId                                            
inner join Severity S on BS.SeverityId = S.SeverityId                                            
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                                            
inner join Priority pr on BS.PriorityId = pr.PriorityId                                            
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                                            
inner join UserMaster UM on Bt.AssignedTo = UM.UserId                                     
inner join UserMaster UMR on bt.CreatedBy = UMR.UserId                                      
inner join Status St on Bt.StatusId = St.StatusId where 1=1'                                            
                     
SET @SQLQuery = @SQLQuery + 'and  convert(VARCHAR(10),isnull(bt.ModifiedOn,bt.CreatedOn),23) >=  '''+ convert(VARCHAR(10),@lastweek,23) + ''''                        
                  
                
                         
 IF(@UserId is not null and @UserId>0)                              
 begin                              
 SET @SQLQuery = @SQLQuery + '  and BS.CreatedBy in (select UserId from AssignedProject where RoleId in (11,12))'      
                          
 end                   
                  
            
SET @SQLQuery = @SQLQuery + '  ) A                                            
WHERE A.RowNum                                            
BETWEEN (((' + convert(VARCHAR(10),@page) + ' - 1) * ' + convert(VARCHAR(10),@pageSize) + ') + 1) AND (' + convert(VARCHAR(10),@page) + ' * ' + convert(VARCHAR(10),@pageSize) + ')      
ORDER BY A.RowNum;'                                            
                                            
print @SQLQuery                      
EXEC (@SQLQuery)                                            
                                            
                             
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_BusinessAnalystLeadBugListGrid]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_BusinessAnalystLeadBugListGrid]                               
@ProjectId int = null,                    
@PriorityId int= null,                    
@SeverityId int= null,                    
@StatusId int = null,                    
@AssignedtoId int = null,           
@ProjectComponentId int = null,                    
@page INT,                    
@pageSize INT ,    
@ReportersUserId INT      
as                    
begin                    
                    
                    
DECLARE @SQLQuery AS NVARCHAR(max)                    
set @SQLQuery = ''                    
SET @SQLQuery = @SQLQuery + '                    
SELECT * FROM                    
(                     
                    
select ROW_NUMBER() OVER (ORDER BY BS.BugId desc) as RowNum,                    
BS.BugId ,                    
BS.Summary ,                    
P.ProjectName ,                    
PC.ComponentName,                    
pr.PriorityName,                    
case when ISNULL(RS.ResolutionId,0) =0 then ''NA'' else rs.Resolution end as Resolution,                    
s.Severity,                    
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,                    
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,                    
UM.FirstName +'' ''+ SUBSTRING(UM.LastName, 1, 1)  as AssignedTo,                   
ST.StatusName,                  
ST.StatusId,            
CONVERT(varchar(10),bt.ClosedOn,126) as ClosedOn,  
TE.TestedOn,  
TE.TestedOnId ,
UMR.FirstName +'' ''+ SUBSTRING(UMR.LastName, 1, 1)  as Reportedby  

from BugSummary BS                    
inner join BugTracking bt on BS.BugId = bt.BugId                    
inner join Projects p on BS.ProjectId = p.ProjectId                    
inner join Severity S on BS.SeverityId = S.SeverityId                    
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                    
inner join Priority pr on BS.PriorityId = pr.PriorityId                    
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                    
inner join UserMaster UM on Bt.AssignedTo = UM.UserId      
inner join UserMaster UMR on BS.CreatedBy = UMR.UserId    
inner join Status St on Bt.StatusId = St.StatusId   
inner join TestedEnvironment TE on BS.TestedOnId = TE.TestedOnId  
where bt.CreatedBy in (select UserId from AssignedProject where ProjectId = '''+ convert(VARCHAR(10),@ProjectId) + '''and RoleId in (11,12))'                    
                    
if(@ProjectId is not null and @ProjectId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.ProjectId = ' + convert(VARCHAR(50),@ProjectId) + ' '                      
 end                     
                    
if(@PriorityId is not null and @PriorityId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.PriorityId = ' + convert(VARCHAR(50),@PriorityId) + ' '                      
 end                     
                    
 if(@SeverityId is not null and @SeverityId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.SeverityId = ' + convert(VARCHAR(50),@SeverityId) + ' '                      
 end                     
                    
 if(@StatusId is not null and @StatusId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  Bt.StatusId = ' + convert(VARCHAR(50),@StatusId) + ' '                      
 end         
         
  if(@AssignedtoId is not null and @AssignedtoId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  Bt.AssignedTo = ' + convert(VARCHAR(50),@AssignedtoId) + ' '                      
 end             
                     
 if(@ProjectComponentId is not null and @ProjectComponentId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.ProjectComponentId = ' + convert(VARCHAR(50),@ProjectComponentId) + ' '                      
 end                     
    
 IF(@ReportersUserId is not null and @ReportersUserId>0)                    
 begin           
 SET @SQLQuery = @SQLQuery + '                     
  and  bt.CreatedBy = ' + convert(VARCHAR(50),@ReportersUserId) + ' '                      
 end         
     
SET @SQLQuery = @SQLQuery + '  ) A                    
WHERE A.RowNum                    
BETWEEN (((' + convert(VARCHAR(10),@page) + ' - 1) * ' + convert(VARCHAR(10),@pageSize) + ') + 1) AND (' + convert(VARCHAR(10),@page) + ' * ' + convert(VARCHAR(10),@pageSize) + ')                    
ORDER BY A.RowNum;'                    
                    
print @SQLQuery                    
EXEC (@SQLQuery)                    
                    
                    
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_BusinessAnalystLeadBugListGridCount]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_BusinessAnalystLeadBugListGridCount]           
@ProjectId int = null,          
@PriorityId int= null,          
@SeverityId int= null,          
@StatusId int = null,          
@ProjectComponentId int = NULL,      
@ReportersUserId INT      
as          
begin          
          
          
DECLARE @SQLQuery AS NVARCHAR(max)          
set @SQLQuery = ''          
SET @SQLQuery = @SQLQuery + '          
          
select  count(1) as ctn          
from BugSummary BS          
inner join BugTracking bt on BS.BugId = bt.BugId          
inner join Projects p on BS.ProjectId = p.ProjectId          
inner join Severity S on BS.SeverityId = S.SeverityId          
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId          
inner join Priority pr on BS.PriorityId = pr.PriorityId          
left join Resolution RS on bt.ResolutionId = RS.ResolutionId          
inner join UserMaster UM on Bt.AssignedTo = UM.UserId           
inner join Status St on Bt.StatusId = St.StatusId  
where bt.CreatedBy in (select UserId from AssignedProject where ProjectId = '''+ convert(VARCHAR(10),@ProjectId) + '''and RoleId in (11,12))'                  
          
if(@ProjectId is not null and @ProjectId>0)          
 begin          
 SET @SQLQuery = @SQLQuery + '           
  and  BS.ProjectId = ' + convert(VARCHAR(50),@ProjectId) + ' '            
 end           
          
if(@PriorityId is not null and @PriorityId>0)          
 begin          
 SET @SQLQuery = @SQLQuery + '           
  and  BS.PriorityId = ' + convert(VARCHAR(50),@PriorityId) + ' '            
 end           
          
 if(@SeverityId is not null and @SeverityId>0)          
 begin          
 SET @SQLQuery = @SQLQuery + '           
  and  BS.SeverityId = ' + convert(VARCHAR(50),@SeverityId) + ' '            
 end           
          
 if(@StatusId is not null and @StatusId>0)          
 begin          
 SET @SQLQuery = @SQLQuery + '           
  and  Bt.StatusId = ' + convert(VARCHAR(50),@StatusId) + ' '            
 end           
          
 if(@ProjectComponentId is not null and @ProjectComponentId>0)          
 begin          
 SET @SQLQuery = @SQLQuery + '           
  and  BS.ProjectComponentId = ' + convert(VARCHAR(50),@ProjectComponentId) + ' '            
 end           
      
 IF(@ReportersUserId is not null and @ReportersUserId>0)                  
 begin                  
 SET @SQLQuery = @SQLQuery + '                   
  and  bt.CreatedBy = ' + convert(VARCHAR(50),@ReportersUserId) + ' '                    
 end            
       
SET @SQLQuery = @SQLQuery + ' '          
          
print @SQLQuery          
EXEC (@SQLQuery)          
          
          
end          
          
--- exec Usp_BugListGridCount 6,1,1,3,1,1,10 
GO
/****** Object:  StoredProcedure [dbo].[Usp_ChangeBugsAssignedTester]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_ChangeBugsAssignedTester]          
 @BugId BIGINT,          
 @AssignedTo int          
AS            
BEGIN            
            
  UPDATE dbo.BugTracking             
        SET           
        BugTracking.CreatedBy =@AssignedTo           
        WHERE BugTracking.BugId = @BugId            
              
END 
GO
/****** Object:  StoredProcedure [dbo].[Usp_ChangeBugsAssignedUser]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_ChangeBugsAssignedUser]        
 @BugId BIGINT,        
 @AssignedTo int        
AS          
BEGIN          
          
  UPDATE dbo.BugTracking           
        SET         
        BugTracking.AssignedTo =@AssignedTo         
        WHERE BugTracking.BugId = @BugId          
            
END 
GO
/****** Object:  StoredProcedure [dbo].[Usp_ChangeBugsPriority]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_ChangeBugsPriority]        
 @BugId BIGINT,        
 @PriorityId int        
AS          
BEGIN          
          
  UPDATE dbo.BugSummary           
        SET         
        BugSummary.PriorityId =@PriorityId         
        WHERE BugSummary.BugId = @BugId          
            
END 
GO
/****** Object:  StoredProcedure [dbo].[Usp_CheckIsUserAssignedAlreadyinUse]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE PROC [dbo].[Usp_CheckIsUserAssignedAlreadyinUse]            
@AssignedProjectId INT,
@RoleId int
AS            
BEGIN            
if	(@RoleId =5 or @RoleId =7or @RoleId =8)
begin
select COUNT(1) from BugTracking where CreatedBy = (select top 1 UserId from AssignedProject ap where AssignedProjectId = @AssignedProjectId )          
end

if	(@RoleId =4 or @RoleId =6)
begin
select COUNT(1) from BugTracking where AssignedTo = (select top 1 UserId from AssignedProject ap where AssignedProjectId = @AssignedProjectId )          
end

end            


GO
/****** Object:  StoredProcedure [dbo].[Usp_Common_GetBrowserNamesofTestedBugs]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_Common_GetBrowserNamesofTestedBugs]        
@ProjectId int ,  
@RoleId int  
AS              
BEGIN              
              
      if(@RoleId =9 or @RoleId = 10)  
begin   
SELECT COUNT(1) AS TotalCount, b.BrowserName as TextValue  FROM dbo.BugSummary bs              
right JOIN dbo.Browsers b ON bs.BrowserId =b.BrowserId          
WHERE bs.ProjectId = @ProjectId  and bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10))         
GROUP BY b.BrowserId , b.BrowserName              
    order by b.BrowserName asc         
end   

      if(@RoleId =11 or @RoleId = 12)  
begin   
SELECT COUNT(1) AS TotalCount, b.BrowserName as TextValue  FROM dbo.BugSummary bs              
right JOIN dbo.Browsers b ON bs.BrowserId =b.BrowserId          
WHERE bs.ProjectId = @ProjectId  and bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12))         
GROUP BY b.BrowserId , b.BrowserName              
    order by b.BrowserName asc         
end   



 end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_Common_GetBugsCountProjectwisebyUserId]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_Common_GetBugsCountProjectwisebyUserId]    
@UserId bigint    
AS    
BEGIN    
    
SELECT sum(CASE WHEN bt.StatusId =1 THEN 1 ELSE 0 end) as 'Open', sum(CASE WHEN bt.StatusId =7 THEN 1 ELSE 0 end) as 'Closed', p.ProjectName  FROM dbo.BugSummary bs    
INNER JOIN dbo.Projects p ON bs.ProjectId =p.ProjectId    
INNER JOIN dbo.BugTracking bt ON bs.BugId =bt.BugId  
WHERE bs.CreatedBy in (select UserId from AssignedProject where UserId =@UserId and RoleId in (9,10))
GROUP BY bs.ProjectId ,p.ProjectName    
    
end    
GO
/****** Object:  StoredProcedure [dbo].[Usp_Common_GetBugsProjectwiseCountbyProjectId]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_Common_GetBugsProjectwiseCountbyProjectId]      
  
@ProjectId int  ,    
@RoleId int    
AS        
BEGIN        
        
 if(@RoleId =9 or @RoleId = 10)    
begin    
    
SELECT COUNT(1) AS TotalCount, s.StatusName  FROM dbo.BugTracking bt        
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId        
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId      
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10)) and bs.ProjectId = @ProjectId    
GROUP BY bt.StatusId, s.StatusName        
    end  
	
 if(@RoleId =11 or @RoleId = 12)    
begin    
    
SELECT COUNT(1) AS TotalCount, s.StatusName  FROM dbo.BugTracking bt        
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId        
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId      
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12)) and bs.ProjectId = @ProjectId    
GROUP BY bt.StatusId, s.StatusName        
    end  

end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_Common_GetBugTypeProjectwiseCount_Reporter]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_Common_GetBugTypeProjectwiseCount_Reporter]        
         
@ProjectId int  ,    
@RoleId int    
as        
begin        
 if(@RoleId =9 or @RoleId = 10)    
begin         
select count(1) as TotalCount ,bt.BugType  as TextValue  from BugSummary bs        
inner join BugTypes bt on bs.BugTypeId = bt.BugTypeId        
WHERE bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10)) AND bs.ProjectId = @ProjectId        
GROUP BY bs.BugTypeId, bt.BugType        
        end    

		 if(@RoleId =11 or @RoleId = 12)    
begin         
select count(1) as TotalCount ,bt.BugType  as TextValue  from BugSummary bs        
inner join BugTypes bt on bs.BugTypeId = bt.BugTypeId        
WHERE bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12)) AND bs.ProjectId = @ProjectId        
GROUP BY bs.BugTypeId, bt.BugType        
        end   
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_Common_GetOpenandClosedCountbyUserId]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_Common_GetOpenandClosedCountbyUserId]        
   
@ProjectId int,    
@RoleId int    
AS        
BEGIN        
      if(@RoleId =9 or @RoleId = 10)    
begin        
SELECT SUM(CASE WHEN bt.StatusId =1 THEN 1 ELSE 0 END) AS 'Open',        
SUM(CASE WHEN bt.StatusId =7 THEN 1 ELSE 0 END) AS 'Closed'        
FROM dbo.BugTracking bt        
inner join BugSummary bs on bt.BugId = bs.BugId        
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10)) and bs.ProjectId = @ProjectId    
    end  
	      if(@RoleId =11 or @RoleId = 12)    
begin        
SELECT SUM(CASE WHEN bt.StatusId =1 THEN 1 ELSE 0 END) AS 'Open',        
SUM(CASE WHEN bt.StatusId =7 THEN 1 ELSE 0 END) AS 'Closed'        
FROM dbo.BugTracking bt        
inner join BugSummary bs on bt.BugId = bs.BugId        
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12)) and bs.ProjectId = @ProjectId    
    end  
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_Common_GetSeverityProjectwiseCount_Reporter]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_Common_GetSeverityProjectwiseCount_Reporter]         
@ProjectId int ,    
@RoleId int    
as        
begin        
if(@RoleId =9 or @RoleId = 10)    
begin        
select count(1) as TotalCount ,s.Severity as TextValue from BugSummary bs        
inner join Severity s on bs.SeverityId = s.SeverityId        
WHERE bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10))  AND bs.ProjectId = @ProjectId         
GROUP BY bs.SeverityId, s.Severity            
      end
	  
	  if(@RoleId =11 or @RoleId = 12)    
begin        
select count(1) as TotalCount ,s.Severity as TextValue from BugSummary bs        
inner join Severity s on bs.SeverityId = s.SeverityId        
WHERE bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12))  AND bs.ProjectId = @ProjectId         
GROUP BY bs.SeverityId, s.Severity            
      end   

end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_Common_GetStatusWiseBugCount_Reporter]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_Common_GetStatusWiseBugCount_Reporter]    

@ProjectId int    
as    
    
begin    
declare @OpenCount          int    
declare @OpenValue          varchar(20)    
declare @ConfirmedCount   int    
declare @ConfirmedValue          varchar(20)    
declare @InProgressCount  int    
declare @InProgressValue          varchar(20)    
declare @ReOpenedCount   int    
declare @ReOpenedValue          varchar(20)    
declare @ResolvedCount   int    
declare @ResolvedValue          varchar(20)    
declare @InTestingCount   int    
declare @InTestingValue          varchar(20)    
declare @ClosedCount    int    
declare @ClosedValue          varchar(20)    
declare @OnHoldCount   int    
declare @OnHoldValue          varchar(20)    
declare @RejectedCount   int    
declare @RejectedValue          varchar(20)    
declare @ReplyCount    int    
declare @ReplyValue          varchar(20)    
declare @DuplicateCount   int    
declare @DuplicateValue          varchar(20)    
declare @UnConfirmedCount  int    
declare @UnConfirmedValue          varchar(20)    
    
    
SELECT @OpenCount = COUNT(1) , @OpenValue = 'Open'  FROM dbo.BugTracking bt        
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId        
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId      
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10))  AND bs.ProjectId =@ProjectId and s.StatusId = 1      
      
SELECT @ConfirmedCount = COUNT(1) , @ConfirmedValue ='Confirmed'   FROM dbo.BugTracking bt        
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId        
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId      
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10))  AND bs.ProjectId =@ProjectId and s.StatusId = 2     
     
SELECT @InProgressCount = COUNT(1) , @InProgressValue ='In-Progress'   FROM dbo.BugTracking bt        
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId        
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId      
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10))  AND bs.ProjectId =@ProjectId and s.StatusId = 3    
     
SELECT @ReOpenedCount =COUNT(1) ,@ReOpenedValue = 'Re-Opened'   FROM dbo.BugTracking bt        
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId        
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId      
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10))  AND bs.ProjectId =@ProjectId and s.StatusId = 4      
     
    
SELECT @ResolvedCount =COUNT(1) , @ResolvedValue ='Resolved'   FROM dbo.BugTracking bt        
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId        
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId      
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10))   AND bs.ProjectId =@ProjectId and s.StatusId = 5      
     
    
SELECT @InTestingCount=COUNT(1) , @InTestingValue='InTesting'   FROM dbo.BugTracking bt        
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId        
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId      
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10))   AND bs.ProjectId =@ProjectId and s.StatusId = 6      
     
    
SELECT @ClosedCount =COUNT(1) ,@ClosedValue = 'Closed'   FROM dbo.BugTracking bt        
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId        
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId      
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10))   AND bs.ProjectId =@ProjectId and s.StatusId = 7     
     
    
SELECT @OnHoldCount =COUNT(1) , @OnHoldValue='On-Hold'   FROM dbo.BugTracking bt        
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId        
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId      
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10))   AND bs.ProjectId =@ProjectId and s.StatusId = 8      
     
    
SELECT @RejectedCount = COUNT(1) , @RejectedValue ='Rejected'   FROM dbo.BugTracking bt        
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId        
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId      
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10))   AND bs.ProjectId =@ProjectId and s.StatusId = 9      
     
    
SELECT @ReplyCount =COUNT(1) , @ReplyValue = 'Reply'   FROM dbo.BugTracking bt        
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId        
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId      
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10))   AND bs.ProjectId =@ProjectId and s.StatusId =10      
     
    
SELECT @DuplicateCount =COUNT(1) , @DuplicateValue ='Duplicate'   FROM dbo.BugTracking bt        
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId        
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId      
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10))   AND bs.ProjectId =@ProjectId and s.StatusId = 11     
    
    
SELECT @UnConfirmedCount = COUNT(1) , @UnConfirmedValue = 'UnConfirmed'     
FROM dbo.BugTracking bt        
right JOIN dbo.Status s ON bt.StatusId =s.StatusId        
right JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId      
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10))   AND bs.ProjectId =@ProjectId and s.StatusId = 12      
    
    
select @OpenCount as OpenCount , @OpenValue as 'Open',          
 @ConfirmedCount  as ConfirmedCount, @ConfirmedValue as 'Confirmed'  ,     
 @InProgressCount as InProgress , @InProgressValue as 'InProgress',    
 @ReOpenedCount as ReOpenedCount ,@ReOpenedValue as 'ReOpened',    
 @ResolvedCount as ResolvedCount , @ResolvedValue as 'Resolved',    
 @InTestingCount as InTestingCount  , @InTestingValue as 'InTesting',    
 @ClosedCount as ClosedCount , @ClosedValue as 'Closed',    
 @OnHoldCount as OnHoldCount  , @OnHoldValue as 'OnHold',    
 @RejectedCount as RejectedCount , @RejectedValue as 'Rejected',    
 @ReplyCount as  ReplyCount  , @ReplyValue as  'Reply',    
 @DuplicateCount as DuplicateCount  , @DuplicateValue as 'Duplicate',    
 @UnConfirmedCount as UnConfirmedCount ,@UnConfirmedValue as 'UnConfirmed'    
    
    
    
End 
GO
/****** Object:  StoredProcedure [dbo].[Usp_common_GetTestedEnvironmentProjectwiseCount_Reporter]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_common_GetTestedEnvironmentProjectwiseCount_Reporter]      
       
@ProjectId int  ,    
@RoleId int    
as      
begin   


   if(@RoleId =9 or @RoleId = 10)    
begin     
select count(1) as TotalCount ,te.TestedOn as TextValue from BugSummary bs      
inner join TestedEnvironment te on bs.TestedOnId = te.TestedOnId      
WHERE bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10)) AND bs.ProjectId = @ProjectId       
GROUP BY bs.TestedOnId, te.TestedOn      
  end 
  
     if(@RoleId =11 or @RoleId = 12)    
begin     
select count(1) as TotalCount ,te.TestedOn as TextValue from BugSummary bs      
inner join TestedEnvironment te on bs.TestedOnId = te.TestedOnId      
WHERE bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12)) AND bs.ProjectId = @ProjectId       
GROUP BY bs.TestedOnId, te.TestedOn      
  end 
  
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_Common_PieChartData]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_Common_PieChartData]        
 @ProjectId int,    
@RoleId int    
AS        
BEGIN        
        
    
if(@RoleId =9 or @RoleId = 10)    
begin    
    
SELECT COUNT(1) AS TotalCount, s.StatusName  FROM dbo.BugTracking bt        
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId        
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId        
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10)) and bs.ProjectId = @ProjectId       
GROUP BY bt.StatusId, s.StatusName        
end    

if(@RoleId =11 or @RoleId = 12)    
begin    
    
SELECT COUNT(1) AS TotalCount, s.StatusName  FROM dbo.BugTracking bt        
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId        
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId        
WHERE bt.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12)) and bs.ProjectId = @ProjectId       
GROUP BY bt.StatusId, s.StatusName        
end   


end        
        
        
        
GO
/****** Object:  StoredProcedure [dbo].[Usp_Common_PriorityPieChartData]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_Common_PriorityPieChartData]          
@ProjectId int,    
@RoleId int    
AS          
BEGIN          
    if(@RoleId =9 or @RoleId = 10)    
begin      
SELECT COUNT(1) AS TotalCount, p.PriorityName  FROM dbo.BugSummary bs          
right JOIN dbo.Priority p ON bs.PriorityId =p.PriorityId        
WHERE bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10)) and bs.ProjectId = @ProjectId    
GROUP BY p.PriorityId, p.PriorityName           
    end    

    if(@RoleId =11 or @RoleId = 12)    
begin      
SELECT COUNT(1) AS TotalCount, p.PriorityName  FROM dbo.BugSummary bs          
right JOIN dbo.Priority p ON bs.PriorityId =p.PriorityId        
WHERE bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12)) and bs.ProjectId = @ProjectId    
GROUP BY p.PriorityId, p.PriorityName           
    end    


end          
          
          
GO
/****** Object:  StoredProcedure [dbo].[Usp_DeleteProjectComponent]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_DeleteProjectComponent]  
@ProjectComponentId int,  
@result varchar(50)=null out    
  
as  
begin  
  
declare @totalcount int  
select @totalcount =count(1) from BugSummary where ProjectComponentId =@ProjectComponentId  
  
if (@totalcount = 0)  
begin  
delete from ProjectComponent where ProjectComponentId =@ProjectComponentId  
set @result = 'success'  
end  
else  
begin  
set @result = 'failed'  
end  
  
end  
  
  
GO
/****** Object:  StoredProcedure [dbo].[Usp_DeveloperPieChartData]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_DeveloperPieChartData]    
@UserId int ,
@ProjectId int
AS    
BEGIN    
    
SELECT COUNT(1) AS TotalCount, s.StatusName  FROM dbo.BugTracking bt  
inner join dbo.BugSummary bs on bt.BugId = bs.BugId
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
WHERE bt.AssignedTo =@UserId   and bs.ProjectId = @ProjectId 
GROUP BY bt.StatusId, s.StatusName    
    
end    
    
    
    
   
GO
/****** Object:  StoredProcedure [dbo].[Usp_DeveloperPriorityPieChartData]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_DeveloperPriorityPieChartData]      
@UserId int ,
@ProjectId int
AS      
BEGIN      
      
SELECT COUNT(1) AS TotalCount, p.PriorityName  FROM dbo.BugSummary bs      
inner JOIN dbo.BugTracking bt ON bs.BugId =bt.BugId    
inner JOIN dbo.Priority p ON bs.PriorityId =p.PriorityId    
WHERE bt.AssignedTo =@UserId and bs.ProjectId =  @ProjectId   
GROUP BY p.PriorityId, p.PriorityName       
    
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetBrowserNamesofBugs]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Usp_GetBrowserNamesofBugs]  
@ProjectId int         
AS        
BEGIN        
        

SELECT COUNT(1) AS TotalCount, b.BrowserName as TextValue  FROM dbo.BugSummary bs        
right JOIN dbo.Browsers b ON bs.BrowserId =b.BrowserId    
WHERE bs.ProjectId = @ProjectId     
GROUP BY b.BrowserId , b.BrowserName        
      
end        
        
        
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetBrowserNamesofTestedBugs]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
    
CREATE PROC [dbo].[Usp_GetBrowserNamesofTestedBugs]      
@ProjectId int             
AS            
BEGIN            
            
    
SELECT COUNT(1) AS TotalCount, b.BrowserName as TextValue  FROM dbo.BugSummary bs            
right JOIN dbo.Browsers b ON bs.BrowserId =b.BrowserId        
WHERE bs.ProjectId = @ProjectId         
GROUP BY b.BrowserId , b.BrowserName            
    order by b.BrowserName             asc       
end            
            
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetBugDetailsbyBugId]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE PROCEDURE [dbo].[Usp_GetBugDetailsbyBugId]            
@BugId BIGINT            
AS            
            
BEGIN            
            
select                
BS.BugId ,                
BS.Summary ,                
P.ProjectName ,                
PC.ComponentName as ProjectComponent,                 
pr.PriorityName AS Priority,                
case when ISNULL(RS.ResolutionId,0) =0 then '---' else rs.Resolution end as Resolution,                
s.Severity AS Severity,                
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,                
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,                
UM.FirstName +' '+ UM.LastName as AssignedTo,                
UMC.FirstName +' '+ UMC.LastName as CreatedBy,                
ST.StatusName,              
ST.StatusId,            
hd.Hardware,            
Os.OperatingSystemName,            
webf.WebFramework,            
TE.TestedOn,            
BTy.BugType as BugTypeOn,            
bt.AssignedTo AS AssignedToId,       
bt.CreatedBy AS TesterId,    
bd.Description,            
b.BrowserName,            
Ve.VersionName as Version ,           
BS.Urls ,        
BS.ProjectId,        
bs.PriorityId,  
UM.DesignationId  
from BugSummary BS                
inner join dbo.BugDetails bd on BS.BugId = bd.BugId               
inner join BugTracking bt on BS.BugId = bt.BugId                
inner join Projects p on BS.ProjectId = p.ProjectId                
inner join Severity S on BS.SeverityId = S.SeverityId                
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                
inner join Priority pr on BS.PriorityId = pr.PriorityId                
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                
inner join UserMaster UM on Bt.AssignedTo = UM.UserId               
inner join UserMaster UMC on BS.CreatedBy = UMC.UserId              
inner join Status St on Bt.StatusId = St.StatusId                 
left join dbo.Hardware hd on BS.HardwareId = hd.HardwareId                
left join dbo.Browsers b on BS.BrowserId = b.BrowserId            
left join dbo.OperatingSystem Os on BS.OperatingSystemId = Os.OperatingSystemId              
left join dbo.WebFrameworks webf on BS.WebFrameworkId = webf.WebFrameworkId              
left join dbo.TestedEnvironment TE on BS.TestedOnId = TE.TestedOnId            
left join dbo.BugTypes BTy on BS.BugTypeId = BTy.BugTypeId              
left join dbo.Version Ve on BS.VersionId = Ve.VersionId     
  
WHERE BS.BugId =@BugId            
end
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetBugDetailsbyCreatedDate_Report]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
-- exec Usp_GetBugDetailsbyCreatedDate_Report 1 ,'2021-01-01','2021-10-30'      
CREATE PROC [dbo].[Usp_GetBugDetailsbyCreatedDate_Report]      
 @ProjectId int,      
 @Fromdate varchar(10),        
 @Todate varchar(10)        
AS      
BEGIN      
      
select                    
BS.BugId ,                    
BS.Summary ,                    
P.ProjectName AS 'Project',                    
PC.ComponentName as  'Component',                            
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,                    
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,             
CONVERT(varchar(10),bt.ClosedOn,126) as ClosedOn,          
UM.FirstName +' '+ UM.LastName as AssignedTo,                    
UMC.FirstName +' '+ UMC.LastName as CreatedBy,                    
ST.StatusName as 'Status',        
pr.PriorityName AS Priority,                          
s.Severity AS Severity,          
case when ISNULL(RS.ResolutionId,0) =0 then '---' else rs.Resolution end as Resolution,             
hd.Hardware,                
Os.OperatingSystemName as  'OperatingSystem',                   
webf.WebFramework,                
TE.TestedOn,                
BTy.BugType as BugType,                     
b.BrowserName as Browser,                
Ve.VersionName as Version ,               
BS.Urls,      
bd.Description      
from BugSummary BS                    
inner join dbo.BugDetails bd on BS.BugId = bd.BugId                   
inner join BugTracking bt on BS.BugId = bt.BugId                    
inner join Projects p on BS.ProjectId = p.ProjectId                    
inner join Severity S on BS.SeverityId = S.SeverityId                    
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                    
inner join Priority pr on BS.PriorityId = pr.PriorityId                    
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                    
inner join UserMaster UM on Bt.AssignedTo = UM.UserId                   
inner join UserMaster UMC on BS.CreatedBy = UMC.UserId                  
inner join Status St on Bt.StatusId = St.StatusId                     
left join dbo.Hardware hd on BS.HardwareId = hd.HardwareId                    
left join dbo.Browsers b on BS.BrowserId = b.BrowserId                
left join dbo.OperatingSystem Os on BS.OperatingSystemId = Os.OperatingSystemId                  
left join dbo.WebFrameworks webf on BS.WebFrameworkId = webf.WebFrameworkId                  
left join dbo.TestedEnvironment TE on BS.TestedOnId = TE.TestedOnId                
left join dbo.BugTypes BTy on BS.BugTypeId = BTy.BugTypeId                  
left join dbo.Version Ve on BS.VersionId = Ve.VersionId         
where CONVERT(varchar(10),bs.CreatedOn,126)  between @Fromdate and @Todate and bs.ProjectId = @ProjectId        
   ORDER BY CONVERT(varchar(10),bs.CreatedOn,126)  
     
end
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetBugHistorybyBugId]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_GetBugHistorybyBugId]
@BugId int
as
begin


SELECT
       Um.FirstName +' '+ UM.LastName as UserName
      ,BH.Message
      ,CONVERT(varchar,BH.ProcessDate,100) as ProcessDate 
      ,BH.UserId
      ,BH.BugId
      ,BH.StatusId
      ,BH.PriorityId
      ,BH.AssignedTo
	  ,UM.Gender as Avatar
  FROM [dbo].[BugHistory] BH
  inner join UserMaster Um on  BH.UserId = Um.UserId
  where bugid =@BugId
end
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetBugsCountProjectwisebyUserId]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_GetBugsCountProjectwisebyUserId]  
@UserId bigint  
AS  
BEGIN  
  
SELECT sum(CASE WHEN bt.StatusId =1 THEN 1 ELSE 0 end) as 'Open', sum(CASE WHEN bt.StatusId =7 THEN 1 ELSE 0 end) as 'Closed', p.ProjectName  FROM dbo.BugSummary bs  
INNER JOIN dbo.Projects p ON bs.ProjectId =p.ProjectId  
INNER JOIN dbo.BugTracking bt ON bs.BugId =bt.BugId
WHERE bs.CreatedBy =@UserId   
GROUP BY bs.ProjectId ,p.ProjectName  
  
end  
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetBugsProjectwiseCountbyProjectId]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_GetBugsProjectwiseCountbyProjectId]
@UserId BIGINT,
@ProjectId int
AS  
BEGIN  
  
SELECT COUNT(1) AS TotalCount, s.StatusName  FROM dbo.BugTracking bt  
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId  
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId
WHERE bt.CreatedBy =@UserId  AND bs.ProjectId = @ProjectId
GROUP BY bt.StatusId, s.StatusName  
  
end  
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetBugTypeProjectwiseCount_Developer]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetBugTypeProjectwiseCount_Developer]
@UserId BIGINT,      
@ProjectId int      
as    
begin    
    
select count(1) as TotalCount ,bty.BugType  as TextValue  from BugSummary bs    
inner join BugTypes bty on bs.BugTypeId = bty.BugTypeId    
inner join BugTracking bt on bt.BugId = bs.BugId
WHERE bt.AssignedTo =@UserId  AND bs.ProjectId = @ProjectId     
GROUP BY bs.BugTypeId, bty.BugType    
        
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetBugTypeProjectwiseCount_Lead]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetBugTypeProjectwiseCount_Lead]         
@ProjectId int          
as        
begin        
        
select count(1) as TotalCount ,bty.BugType  as TextValue  from BugSummary bs        
inner join BugTypes bty on bs.BugTypeId = bty.BugTypeId        
inner join BugTracking bt on bt.BugId = bs.BugId    
WHERE bs.ProjectId = @ProjectId         
GROUP BY bs.BugTypeId, bty.BugType        
      order by bty.BugType   asc         
end   
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetBugTypeProjectwiseCount_Reporter]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetBugTypeProjectwiseCount_Reporter]  
@UserId BIGINT,    
@ProjectId int    
as  
begin  
  
select count(1) as TotalCount ,bt.BugType  as TextValue  from BugSummary bs  
inner join BugTypes bt on bs.BugTypeId = bt.BugTypeId  
WHERE bs.CreatedBy =@UserId  AND bs.ProjectId = @ProjectId  
GROUP BY bs.BugTypeId, bt.BugType  
      
end  
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetBussinessandTeamLeadAssignedtoProject]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_GetBussinessandTeamLeadAssignedtoProject]            
@ProjectId INT          
AS            
BEGIN            
            
SELECT CONVERT(VARCHAR(10),Ap.UserId) AS Value,            
UMR.FirstName +' '+ UMR.LastName as Text            
FROM dbo.AssignedProject Ap            
inner join UserMaster UMR on Ap.UserId = UMR.UserId               
WHERE ap.RoleId IN (11,12) AND AP.ProjectId =@ProjectId            
   order by UMR.FirstName asc         
end 


GO
/****** Object:  StoredProcedure [dbo].[Usp_GetCommonBugDetailsbyCreatedDate_Report]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
-- exec Usp_GetBugDetailsbyCreatedDate_Report 1 ,'2021-01-01','2021-10-30'        
CREATE PROC [dbo].[Usp_GetCommonBugDetailsbyCreatedDate_Report]        
 @ProjectId int,        
 @Fromdate varchar(10),          
 @Todate varchar(10),
  @RoleId int
AS        
BEGIN        
    if(@RoleId = 9 or @RoleId = 10) 
	   begin         
select                      
BS.BugId ,                      
BS.Summary ,                      
P.ProjectName AS 'Project',                      
PC.ComponentName as  'Component',                              
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,                      
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,               
CONVERT(varchar(10),bt.ClosedOn,126) as ClosedOn,            
UM.FirstName +' '+ UM.LastName as AssignedTo,                      
UMC.FirstName +' '+ UMC.LastName as CreatedBy,                      
ST.StatusName as 'Status',          
pr.PriorityName AS Priority,                            
s.Severity AS Severity,            
case when ISNULL(RS.ResolutionId,0) =0 then '---' else rs.Resolution end as Resolution,               
hd.Hardware,                  
Os.OperatingSystemName as  'OperatingSystem',                     
webf.WebFramework,                  
TE.TestedOn,                  
BTy.BugType as BugType,                       
b.BrowserName as Browser,                  
Ve.VersionName as Version ,                 
BS.Urls,        
bd.Description        
from BugSummary BS                      
inner join dbo.BugDetails bd on BS.BugId = bd.BugId                     
inner join BugTracking bt on BS.BugId = bt.BugId                      
inner join Projects p on BS.ProjectId = p.ProjectId                      
inner join Severity S on BS.SeverityId = S.SeverityId                      
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                      
inner join Priority pr on BS.PriorityId = pr.PriorityId                      
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                      
inner join UserMaster UM on Bt.AssignedTo = UM.UserId                     
inner join UserMaster UMC on BS.CreatedBy = UMC.UserId                    
inner join Status St on Bt.StatusId = St.StatusId                       
left join dbo.Hardware hd on BS.HardwareId = hd.HardwareId                      
left join dbo.Browsers b on BS.BrowserId = b.BrowserId                  
left join dbo.OperatingSystem Os on BS.OperatingSystemId = Os.OperatingSystemId                    
left join dbo.WebFrameworks webf on BS.WebFrameworkId = webf.WebFrameworkId                    
left join dbo.TestedEnvironment TE on BS.TestedOnId = TE.TestedOnId                  
left join dbo.BugTypes BTy on BS.BugTypeId = BTy.BugTypeId                    
left join dbo.Version Ve on BS.VersionId = Ve.VersionId           
where CONVERT(varchar(10),bs.CreatedOn,126)  between @Fromdate and @Todate and bs.ProjectId = @ProjectId    and bt.CreatedBy in (select UserId from AssignedProject where ProjectId = @ProjectId and RoleId in (9,10))            
   ORDER BY CONVERT(varchar(10),bs.CreatedOn,126)    
end
  if(@RoleId = 11 or @RoleId = 12) 
	   begin         
select                      
BS.BugId ,                      
BS.Summary ,                      
P.ProjectName AS 'Project',                      
PC.ComponentName as  'Component',                              
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,                      
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,               
CONVERT(varchar(10),bt.ClosedOn,126) as ClosedOn,            
UM.FirstName +' '+ UM.LastName as AssignedTo,                      
UMC.FirstName +' '+ UMC.LastName as CreatedBy,                      
ST.StatusName as 'Status',          
pr.PriorityName AS Priority,                            
s.Severity AS Severity,            
case when ISNULL(RS.ResolutionId,0) =0 then '---' else rs.Resolution end as Resolution,               
hd.Hardware,                  
Os.OperatingSystemName as  'OperatingSystem',                     
webf.WebFramework,                  
TE.TestedOn,                  
BTy.BugType as BugType,                       
b.BrowserName as Browser,                  
Ve.VersionName as Version ,                 
BS.Urls,        
bd.Description        
from BugSummary BS                      
inner join dbo.BugDetails bd on BS.BugId = bd.BugId                     
inner join BugTracking bt on BS.BugId = bt.BugId                      
inner join Projects p on BS.ProjectId = p.ProjectId                      
inner join Severity S on BS.SeverityId = S.SeverityId                      
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                      
inner join Priority pr on BS.PriorityId = pr.PriorityId                      
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                      
inner join UserMaster UM on Bt.AssignedTo = UM.UserId                     
inner join UserMaster UMC on BS.CreatedBy = UMC.UserId                    
inner join Status St on Bt.StatusId = St.StatusId                       
left join dbo.Hardware hd on BS.HardwareId = hd.HardwareId                      
left join dbo.Browsers b on BS.BrowserId = b.BrowserId                  
left join dbo.OperatingSystem Os on BS.OperatingSystemId = Os.OperatingSystemId                    
left join dbo.WebFrameworks webf on BS.WebFrameworkId = webf.WebFrameworkId                    
left join dbo.TestedEnvironment TE on BS.TestedOnId = TE.TestedOnId                  
left join dbo.BugTypes BTy on BS.BugTypeId = BTy.BugTypeId                    
left join dbo.Version Ve on BS.VersionId = Ve.VersionId           
where CONVERT(varchar(10),bs.CreatedOn,126)  between @Fromdate and @Todate and bs.ProjectId = @ProjectId    and bt.CreatedBy in (select UserId from AssignedProject where ProjectId = @ProjectId and RoleId in (11,12))            
   ORDER BY CONVERT(varchar(10),bs.CreatedOn,126)    
end

end
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetCommonBugOpenCloseDetails_Report]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
        
CREATE proc [dbo].[Usp_GetCommonBugOpenCloseDetails_Report]          
 @ProjectId int,        
 @Fromdate varchar(10),        
 @Todate varchar(10),
 @RoleId int
as              
begin          
  if(@RoleId = 9 or @RoleId = 10) 
	   begin         
select bt.BugId ,         
CONVERT(varchar(10),bs.CreatedOn,103) as CreatedOn ,        
case when ISNULL(bt.ClosedOn,'') =''  then '---' else CONVERT(varchar(10),bt.ClosedOn,103) end as 'ClosedOn',        
UM.FirstName+' '+UM.LastName as 'Createdby',        
UMA.FirstName+' '+UMA.LastName as 'AssignedTo',          
bs.Summary,        
s.StatusName as 'Status',        
case when ISNULL(bt.ResolutionId,'') =''  then '---' else rs.Resolution end as 'Resolution'        
from BugTracking bt        
inner join BugSummary bs on bt.BugId = bs.BugId        
inner join UserMaster UM on bs.CreatedBy = UM.UserId        
inner join UserMaster UMA on bt.AssignedTo = UMA.UserId            
inner join Status S on bt.StatusId = s.StatusId        
left join Resolution rs on bt.ResolutionId = rs.ResolutionId        
where CONVERT(varchar(10),bs.CreatedOn,126)  between @Fromdate and @Todate and bs.ProjectId = @ProjectId and bt.CreatedBy in (select UserId from AssignedProject where ProjectId = @ProjectId and RoleId in (9,10))              
 ORDER BY CONVERT(varchar(10),bs.CreatedOn,126) asc
 end
  if(@RoleId = 11 or @RoleId = 12) 
	   begin         
select bt.BugId ,         
CONVERT(varchar(10),bs.CreatedOn,103) as CreatedOn ,        
case when ISNULL(bt.ClosedOn,'') =''  then '---' else CONVERT(varchar(10),bt.ClosedOn,103) end as 'ClosedOn',        
UM.FirstName+' '+UM.LastName as 'Createdby',        
UMA.FirstName+' '+UMA.LastName as 'AssignedTo',          
bs.Summary,        
s.StatusName as 'Status',        
case when ISNULL(bt.ResolutionId,'') =''  then '---' else rs.Resolution end as 'Resolution'        
from BugTracking bt        
inner join BugSummary bs on bt.BugId = bs.BugId        
inner join UserMaster UM on bs.CreatedBy = UM.UserId        
inner join UserMaster UMA on bt.AssignedTo = UMA.UserId            
inner join Status S on bt.StatusId = s.StatusId        
left join Resolution rs on bt.ResolutionId = rs.ResolutionId        
where CONVERT(varchar(10),bs.CreatedOn,126)  between @Fromdate and @Todate and bs.ProjectId = @ProjectId and bt.CreatedBy in (select UserId from AssignedProject where ProjectId = @ProjectId and RoleId in (11,12))              
 ORDER BY CONVERT(varchar(10),bs.CreatedOn,126) asc
 end
end


GO
/****** Object:  StoredProcedure [dbo].[Usp_GetCommonTeamWiseProjectComponent_Report]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
          
-- exec Usp_GetCommonTeamWiseProjectComponent_Report 1,9          
CREATE proc [dbo].[Usp_GetCommonTeamWiseProjectComponent_Report]            
 @ProjectId int,
 @RoleId int
as                
begin                
 if(@RoleId = 9 or @RoleId = 10) 
	   begin                
select             
p.ProjectName as 'Project',          
PC.ComponentName as 'Component',          
um.FirstName +' '+um.LastName as 'User',             
sum(case when bt.StatusId = 1 then 1 else 0 end) as 'Open',            
sum(case when bt.StatusId = 2 then 1 else 0 end) as 'Confirmed',            
sum(case when bt.StatusId = 3 then 1 else 0 end) as 'InProgress',            
sum(case when bt.StatusId = 4 then 1 else 0 end) as 'ReOpened',            
sum(case when bt.StatusId = 5 then 1 else 0 end) as 'Resolved',            
sum(case when bt.StatusId = 6 then 1 else 0 end) as 'InTesting',            
sum(case when bt.StatusId = 7 then 1 else 0 end) as 'Closed',            
sum(case when bt.StatusId = 8 then 1 else 0 end) as 'OnHold',            
sum(case when bt.StatusId = 9 then 1 else 0 end) as 'Rejected',            
sum(case when bt.StatusId = 10 then 1 else 0 end) as 'Reply',            
sum(case when bt.StatusId = 11 then 1 else 0 end) as 'Duplicate',            
sum(case when bt.StatusId = 12 then 1 else 0 end) as 'UnConfirmed'            
from BugSummary bs            
inner join BugTracking bt on bs.BugId = bt.BugId            
inner join UserMaster UM on bt.CreatedBy = um.UserId            
inner join Projects p on bs.ProjectId = p.ProjectId           
inner join ProjectComponent PC on bs.ProjectComponentId = pc.ProjectComponentId          
where bs.ProjectId =@ProjectId        and bt.CreatedBy in (select UserId from AssignedProject where ProjectId = @ProjectId and RoleId in (9,10))                  
GROUP BY p.ProjectName,PC.ComponentName,um.FirstName +' '+um.LastName            
   ORDER BY p.ProjectName,PC.ComponentName,um.FirstName +' '+um.LastName  asc                 
end 
 if(@RoleId = 11 or @RoleId = 12) 
	   begin                
select             
p.ProjectName as 'Project',          
PC.ComponentName as 'Component',          
um.FirstName +' '+um.LastName as 'User',             
sum(case when bt.StatusId = 1 then 1 else 0 end) as 'Open',            
sum(case when bt.StatusId = 2 then 1 else 0 end) as 'Confirmed',            
sum(case when bt.StatusId = 3 then 1 else 0 end) as 'InProgress',            
sum(case when bt.StatusId = 4 then 1 else 0 end) as 'ReOpened',            
sum(case when bt.StatusId = 5 then 1 else 0 end) as 'Resolved',            
sum(case when bt.StatusId = 6 then 1 else 0 end) as 'InTesting',            
sum(case when bt.StatusId = 7 then 1 else 0 end) as 'Closed',            
sum(case when bt.StatusId = 8 then 1 else 0 end) as 'OnHold',            
sum(case when bt.StatusId = 9 then 1 else 0 end) as 'Rejected',            
sum(case when bt.StatusId = 10 then 1 else 0 end) as 'Reply',            
sum(case when bt.StatusId = 11 then 1 else 0 end) as 'Duplicate',            
sum(case when bt.StatusId = 12 then 1 else 0 end) as 'UnConfirmed'            
from BugSummary bs            
inner join BugTracking bt on bs.BugId = bt.BugId            
inner join UserMaster UM on bt.CreatedBy = um.UserId            
inner join Projects p on bs.ProjectId = p.ProjectId           
inner join ProjectComponent PC on bs.ProjectComponentId = pc.ProjectComponentId          
where bs.ProjectId =@ProjectId        and bt.CreatedBy in (select UserId from AssignedProject where ProjectId = @ProjectId and RoleId in (11,12))                  
GROUP BY p.ProjectName,PC.ComponentName,um.FirstName +' '+um.LastName            
ORDER BY p.ProjectName,PC.ComponentName,um.FirstName +' '+um.LastName  asc            

end 
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetCommonTeamWiseStatusCount_Lead]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetCommonTeamWiseStatusCount_Lead]          
 @ProjectId int,  
 @RoleId int  
as              
begin              
   if(@RoleId =9 or @RoleId = 10)    
begin               
select           
um.FirstName +' '+um.LastName as 'Names',           
sum(case when bt.StatusId = 1 then 1 else 0 end) as 'Open',          
sum(case when bt.StatusId = 2 then 1 else 0 end) as 'Confirmed',          
sum(case when bt.StatusId = 3 then 1 else 0 end) as 'InProgress',          
sum(case when bt.StatusId = 4 then 1 else 0 end) as 'ReOpened',          
sum(case when bt.StatusId = 5 then 1 else 0 end) as 'Resolved',          
sum(case when bt.StatusId = 6 then 1 else 0 end) as 'InTesting',          
sum(case when bt.StatusId = 7 then 1 else 0 end) as 'Closed',          
sum(case when bt.StatusId = 8 then 1 else 0 end) as 'OnHold',          
sum(case when bt.StatusId = 9 then 1 else 0 end) as 'Rejected',          
sum(case when bt.StatusId = 10 then 1 else 0 end) as 'Reply',          
sum(case when bt.StatusId = 11 then 1 else 0 end) as 'Duplicate',          
sum(case when bt.StatusId = 12 then 1 else 0 end) as 'UnConfirmed',        
COALESCE(sum(case when bt.StatusId = 1 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 2 then 1 else 0 end),0) +        
COALESCE(sum(case when bt.StatusId = 3 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 4 then 1 else 0 end),0) +        
COALESCE(sum(case when bt.StatusId = 5 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 6 then 1 else 0 end),0) +        
COALESCE(sum(case when bt.StatusId = 7 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 8 then 1 else 0 end),0) +        
COALESCE(sum(case when bt.StatusId = 9 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 10 then 1 else 0 end),0) +        
COALESCE(sum(case when bt.StatusId = 11 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 12 then 1 else 0 end),0) AS 'Total'      
from BugSummary bs          
inner join BugTracking bt on bs.BugId = bt.BugId          
inner join UserMaster UM on bt.CreatedBy = um.UserId          
where bs.ProjectId =@ProjectId and bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10))         
GROUP BY um.FirstName +' '+um.LastName          
  End
  
 if(@RoleId =11 or @RoleId = 12)    
begin    
select           
um.FirstName +' '+um.LastName as 'Names',           
sum(case when bt.StatusId = 1 then 1 else 0 end) as 'Open',          
sum(case when bt.StatusId = 2 then 1 else 0 end) as 'Confirmed',          
sum(case when bt.StatusId = 3 then 1 else 0 end) as 'InProgress',          
sum(case when bt.StatusId = 4 then 1 else 0 end) as 'ReOpened',          
sum(case when bt.StatusId = 5 then 1 else 0 end) as 'Resolved',          
sum(case when bt.StatusId = 6 then 1 else 0 end) as 'InTesting',          
sum(case when bt.StatusId = 7 then 1 else 0 end) as 'Closed',          
sum(case when bt.StatusId = 8 then 1 else 0 end) as 'OnHold',          
sum(case when bt.StatusId = 9 then 1 else 0 end) as 'Rejected',          
sum(case when bt.StatusId = 10 then 1 else 0 end) as 'Reply',          
sum(case when bt.StatusId = 11 then 1 else 0 end) as 'Duplicate',          
sum(case when bt.StatusId = 12 then 1 else 0 end) as 'UnConfirmed',        
COALESCE(sum(case when bt.StatusId = 1 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 2 then 1 else 0 end),0) +        
COALESCE(sum(case when bt.StatusId = 3 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 4 then 1 else 0 end),0) +        
COALESCE(sum(case when bt.StatusId = 5 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 6 then 1 else 0 end),0) +        
COALESCE(sum(case when bt.StatusId = 7 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 8 then 1 else 0 end),0) +        
COALESCE(sum(case when bt.StatusId = 9 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 10 then 1 else 0 end),0) +        
COALESCE(sum(case when bt.StatusId = 11 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 12 then 1 else 0 end),0) AS 'Total'      
from BugSummary bs          
inner join BugTracking bt on bs.BugId = bt.BugId          
inner join UserMaster UM on bt.CreatedBy = um.UserId          
where bs.ProjectId =@ProjectId and bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12))         
GROUP BY um.FirstName +' '+um.LastName         
end   


  end  
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetCommonTeamWiseStatusCount_Report]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Usp_GetCommonTeamWiseStatusCount_Report]        
 @ProjectId int ,
 @RoleId int 
as        
        
begin 

       if(@RoleId = 9 or @RoleId = 10) 
	   begin
select               
um.FirstName +' '+um.LastName as 'User',           
p.ProjectName AS 'Project',          
sum(case when bt.StatusId = 1 then 1 else 0 end) as 'Open',              
sum(case when bt.StatusId = 2 then 1 else 0 end) as 'Confirmed',              
sum(case when bt.StatusId = 3 then 1 else 0 end) as 'InProgress',              
sum(case when bt.StatusId = 4 then 1 else 0 end) as 'ReOpened',              
sum(case when bt.StatusId = 5 then 1 else 0 end) as 'Resolved',              
sum(case when bt.StatusId = 6 then 1 else 0 end) as 'InTesting',              
sum(case when bt.StatusId = 7 then 1 else 0 end) as 'Closed',              
sum(case when bt.StatusId = 8 then 1 else 0 end) as 'OnHold',              
sum(case when bt.StatusId = 9 then 1 else 0 end) as 'Rejected',              
sum(case when bt.StatusId = 10 then 1 else 0 end) as 'Reply',              
sum(case when bt.StatusId = 11 then 1 else 0 end) as 'Duplicate',              
sum(case when bt.StatusId = 12 then 1 else 0 end) as 'UnConfirmed'              
from BugSummary bs              
inner join BugTracking bt on bs.BugId = bt.BugId              
inner join UserMaster um on bt.CreatedBy = um.UserId              
inner join dbo.Projects p on bs.ProjectId =p.ProjectId             
where bs.ProjectId =@ProjectId and bt.CreatedBy in (select UserId from AssignedProject where ProjectId = @ProjectId and RoleId in (9,10))               
GROUP BY  p.ProjectName   ,       um.FirstName +' '+um.LastName    
  ORDER BY p.ProjectName  , um.FirstName +' '+um.LastName asc    
  end

         if(@RoleId = 11 or @RoleId = 12) 
	   begin
select               
um.FirstName +' '+um.LastName as 'User',           
p.ProjectName AS 'Project',          
sum(case when bt.StatusId = 1 then 1 else 0 end) as 'Open',              
sum(case when bt.StatusId = 2 then 1 else 0 end) as 'Confirmed',              
sum(case when bt.StatusId = 3 then 1 else 0 end) as 'InProgress',              
sum(case when bt.StatusId = 4 then 1 else 0 end) as 'ReOpened',              
sum(case when bt.StatusId = 5 then 1 else 0 end) as 'Resolved',              
sum(case when bt.StatusId = 6 then 1 else 0 end) as 'InTesting',              
sum(case when bt.StatusId = 7 then 1 else 0 end) as 'Closed',              
sum(case when bt.StatusId = 8 then 1 else 0 end) as 'OnHold',              
sum(case when bt.StatusId = 9 then 1 else 0 end) as 'Rejected',              
sum(case when bt.StatusId = 10 then 1 else 0 end) as 'Reply',              
sum(case when bt.StatusId = 11 then 1 else 0 end) as 'Duplicate',              
sum(case when bt.StatusId = 12 then 1 else 0 end) as 'UnConfirmed'              
from BugSummary bs              
inner join BugTracking bt on bs.BugId = bt.BugId              
inner join UserMaster um on bt.CreatedBy = um.UserId              
inner join dbo.Projects p on bs.ProjectId =p.ProjectId             
where bs.ProjectId =@ProjectId and bt.CreatedBy in (select UserId from AssignedProject where ProjectId = @ProjectId and RoleId in (11,12))               
GROUP BY  p.ProjectName   ,       um.FirstName +' '+um.LastName    
  ORDER BY p.ProjectName  , um.FirstName +' '+um.LastName asc    
  end

end
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetCommonTimeTakeReport]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetCommonTimeTakeReport]  
@ProjectId int ,
 @RoleId int
as  
  
begin  
  if(@RoleId = 9 or @RoleId = 10) 
	   begin   
select   
P.ProjectName,  
dbo.fn_GetDaysAndTimeFromDate(bt.CreatedOn,bt.ClosedOn) as Timetaken,  
UM.FirstName+' '+UM.LastName as 'Createdby',          
UMA.FirstName+' '+UMA.LastName as 'AssignedTo',   
bs.Summary,          
s.StatusName as 'Status' ,  
case when ISNULL(bt.ResolutionId,'') =''  then '---' else rs.Resolution end as 'Resolution',  
CONVERT(varchar(10),bs.CreatedOn,103) as CreatedOn ,          
case when ISNULL(bt.ClosedOn,'') =''  then '---' else CONVERT(varchar(10),bt.ClosedOn,103) end as 'ClosedOn'  
from BugTracking bt  
inner join BugSummary bs on bt.BugId = bs.BugId          
inner join UserMaster UM on bs.CreatedBy = UM.UserId          
inner join UserMaster UMA on bt.AssignedTo = UMA.UserId              
inner join Status S on bt.StatusId = s.StatusId          
left join Resolution rs on bt.ResolutionId = rs.ResolutionId     
inner join Projects P on bs.ProjectId = p.ProjectId  
  
where bs.ProjectId = @ProjectId  and bt.CreatedBy in (select UserId from AssignedProject where ProjectId = @ProjectId and RoleId in (9,10))
end
  if(@RoleId = 11 or @RoleId = 12) 
	   begin   
select   
P.ProjectName,  
dbo.fn_GetDaysAndTimeFromDate(bt.CreatedOn,bt.ClosedOn) as Timetaken,  
UM.FirstName+' '+UM.LastName as 'Createdby',          
UMA.FirstName+' '+UMA.LastName as 'AssignedTo',   
bs.Summary,          
s.StatusName as 'Status' ,  
case when ISNULL(bt.ResolutionId,'') =''  then '---' else rs.Resolution end as 'Resolution',  
CONVERT(varchar(10),bs.CreatedOn,103) as CreatedOn ,          
case when ISNULL(bt.ClosedOn,'') =''  then '---' else CONVERT(varchar(10),bt.ClosedOn,103) end as 'ClosedOn'  
from BugTracking bt  
inner join BugSummary bs on bt.BugId = bs.BugId          
inner join UserMaster UM on bs.CreatedBy = UM.UserId          
inner join UserMaster UMA on bt.AssignedTo = UMA.UserId              
inner join Status S on bt.StatusId = s.StatusId          
left join Resolution rs on bt.ResolutionId = rs.ResolutionId     
inner join Projects P on bs.ProjectId = p.ProjectId  
  
where bs.ProjectId = @ProjectId  and bt.CreatedBy in (select UserId from AssignedProject where ProjectId = @ProjectId and RoleId in (11,12))
end
end   
  
--Usp_GetTimeTakeReport 1
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetDeveloperBugOpenCloseDetails_Report]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
  -- exec Usp_GetDeveloperBugOpenCloseDetails_Report 1,"2021-11-01","2021-12-31"  
CREATE proc [dbo].[Usp_GetDeveloperBugOpenCloseDetails_Report]      
 @ProjectId int,    
 @Fromdate varchar(10),    
 @Todate varchar(10)    
as          
begin      
    
select bt.BugId ,     
CONVERT(varchar(10),bs.CreatedOn,103) as CreatedOn ,    
case when ISNULL(bt.ClosedOn,'') =''  then '---' else CONVERT(varchar(10),bt.ClosedOn,103) end as 'ClosedOn',    
UM.FirstName+''+UM.LastName as 'Createdby',    
UMA.FirstName+''+UMA.LastName as 'AssignedTo',      
bs.Summary,    
s.StatusName as 'Status',    
case when ISNULL(bt.ResolutionId,'') =''  then '---' else rs.Resolution end as 'Resolution'    
from BugTracking bt    
inner join BugSummary bs on bt.BugId = bs.BugId    
inner join UserMaster UM on bs.CreatedBy = UM.UserId    
inner join UserMaster UMA on bt.AssignedTo = UMA.UserId        
inner join Status S on bt.StatusId = s.StatusId    
left join Resolution rs on bt.ResolutionId = rs.ResolutionId    
where CONVERT(varchar(10),bs.CreatedOn,126)  between @Fromdate and @Todate and bs.ProjectId = @ProjectId    
  ORDER BY CONVERT(varchar(10),bs.CreatedOn,126)  
end
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetDeveloperBugsProjectwiseCountbyProjectId]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_GetDeveloperBugsProjectwiseCountbyProjectId]  
@UserId BIGINT,  
@ProjectId int  
AS    
BEGIN    
    
SELECT COUNT(1) AS TotalCount, s.StatusName  FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.AssignedTo =@UserId  AND bs.ProjectId = @ProjectId  
GROUP BY bt.StatusId, s.StatusName    
    
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetDeveloperListbyName]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetDeveloperListbyName]    
@ProjectId int
as    
begin    
    
select u.FirstName +' '+ u.LastName as CustomName , u.UserId , u.UserName from AssignedProject AP   
inner join UserMaster u on  AP.UserId = u.UserId   
where AP.RoleId = 4 and AP.Status = 1 and u.Status =1 and  AP.ProjectId = @ProjectId
    
end 

GO
/****** Object:  StoredProcedure [dbo].[Usp_GetDevelopersandTeamLeadAssignedtoProject]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
CREATE PROC [dbo].[Usp_GetDevelopersandTeamLeadAssignedtoProject]                
@ProjectId INT              
AS                
BEGIN                
                
SELECT CONVERT(VARCHAR(10),Ap.UserId)   AS Value,                
UMR.FirstName +' '+ UMR.LastName +' | '+ DM.Designation as Text                
FROM dbo.AssignedProject Ap                
inner join UserMaster UMR on Ap.UserId = UMR.UserId                 
inner join SavedAssignedRoles SAR on Ap.UserId = SAR.UserId                 
inner join DesignationMaster DM on UMR.DesignationId = DM.DesignationId                  
WHERE  DM.DesignationId   in (2,3,5,8,20,9,4)   AND AP.ProjectId =@ProjectId  and ap.Status = 1 and UMR.Status =1           
order by UMR.FirstName asc  
                
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetDevelopersandTeamLeadAssignedtoProjectbutSelf]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_GetDevelopersandTeamLeadAssignedtoProjectbutSelf]      
@ProjectId INT  ,  
@CurrentUserId Int, 
@Username varchar(50)
AS      
BEGIN      
      
SELECT top 5 CONVERT(VARCHAR(10),Ap.UserId)   AS UserId,      
UMR.FirstName +' '+ UMR.LastName +' | '+ RM.RoleName as CustomName ,  
UMR.UserName  
FROM dbo.AssignedProject Ap      
inner join UserMaster UMR on Ap.UserId = UMR.UserId       
inner join SavedAssignedRoles SAR on Ap.UserId = SAR.UserId       
inner join RoleMaster RM on SAR.RoleId = RM.RoleId        
WHERE ap.RoleId in (4,6) AND AP.ProjectId =@ProjectId 
and  Ap.UserId !=   @CurrentUserId  
and UMR.FirstName like @Username +'%'     

end      
      
  
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetDevelopersBugsCountProjectwisebyUserId]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_GetDevelopersBugsCountProjectwisebyUserId]    
@UserId bigint    
AS    
BEGIN    
    
SELECT sum(CASE WHEN bt.StatusId =1 THEN 1 ELSE 0 end) as 'Open', sum(CASE WHEN bt.StatusId =7 THEN 1 ELSE 0 end) as 'Closed', p.ProjectName  FROM dbo.BugSummary bs    
INNER JOIN dbo.Projects p ON bs.ProjectId =p.ProjectId    
INNER JOIN dbo.BugTracking bt ON bs.BugId =bt.BugId  
WHERE bt.AssignedTo =@UserId     
GROUP BY bs.ProjectId ,p.ProjectName    
    
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetDeveloperTeamLeadAssignedtoProject]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
CREATE PROC [dbo].[Usp_GetDeveloperTeamLeadAssignedtoProject]          
@ProjectId INT        
AS          
BEGIN          
          
SELECT CONVERT(VARCHAR(10),Ap.UserId)   AS Value,          
UMR.FirstName +' '+ UMR.LastName +' | '+ DM.Designation as Text      
FROM dbo.AssignedProject Ap          
inner join UserMaster UMR on Ap.UserId = UMR.UserId           
inner join SavedAssignedRoles SAR on Ap.UserId = SAR.UserId           
inner join DesignationMaster DM on UMR.DesignationId = DM.DesignationId                
WHERE ap.RoleId in (6) AND AP.ProjectId =@ProjectId  and ap.Status = 1 and UMR.Status =1       
 order by UMR.FirstName asc  
   
end          
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetDeveloperTeamWiseProjectComponent_Report]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
      
-- exec Usp_GetDeveloperTeamWiseProjectComponent_Report 1      
CREATE proc [dbo].[Usp_GetDeveloperTeamWiseProjectComponent_Report]        
 @ProjectId int              
as            
begin            
            
select         
p.ProjectName as 'Project',      
PC.ComponentName as 'Component',      
um.FirstName +' '+um.LastName as 'Developer',         
sum(case when bt.StatusId = 1 then 1 else 0 end) as 'Open',        
sum(case when bt.StatusId = 2 then 1 else 0 end) as 'Confirmed',        
sum(case when bt.StatusId = 3 then 1 else 0 end) as 'InProgress',        
sum(case when bt.StatusId = 4 then 1 else 0 end) as 'ReOpened',        
sum(case when bt.StatusId = 5 then 1 else 0 end) as 'Resolved',        
sum(case when bt.StatusId = 6 then 1 else 0 end) as 'InTesting',        
sum(case when bt.StatusId = 7 then 1 else 0 end) as 'Closed',        
sum(case when bt.StatusId = 8 then 1 else 0 end) as 'OnHold',        
sum(case when bt.StatusId = 9 then 1 else 0 end) as 'Rejected',        
sum(case when bt.StatusId = 10 then 1 else 0 end) as 'Reply',        
sum(case when bt.StatusId = 11 then 1 else 0 end) as 'Duplicate',        
sum(case when bt.StatusId = 12 then 1 else 0 end) as 'UnConfirmed'        
from BugSummary bs        
inner join BugTracking bt on bs.BugId = bt.BugId        
inner join UserMaster UM on bt.AssignedTo = um.UserId        
inner join Projects p on bs.ProjectId = p.ProjectId       
inner join ProjectComponent PC on bs.ProjectComponentId = pc.ProjectComponentId      
where bs.ProjectId =@ProjectId         
GROUP BY p.ProjectName,PC.ComponentName,um.FirstName +' '+um.LastName        
  ORDER BY p.ProjectName,PC.ComponentName ,um.FirstName+' '+um.LastName asc             
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetDeveloperTeamWiseStatusCount_Lead]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetDeveloperTeamWiseStatusCount_Lead]      
 @ProjectId int            
as          
begin          
          
select       
um.FirstName +' '+um.LastName as 'Names',       
sum(case when bt.StatusId = 1 then 1 else 0 end) as 'Open',      
sum(case when bt.StatusId = 2 then 1 else 0 end) as 'Confirmed',      
sum(case when bt.StatusId = 3 then 1 else 0 end) as 'InProgress',      
sum(case when bt.StatusId = 4 then 1 else 0 end) as 'ReOpened',      
sum(case when bt.StatusId = 5 then 1 else 0 end) as 'Resolved',      
sum(case when bt.StatusId = 6 then 1 else 0 end) as 'InTesting',      
sum(case when bt.StatusId = 7 then 1 else 0 end) as 'Closed',      
sum(case when bt.StatusId = 8 then 1 else 0 end) as 'OnHold',      
sum(case when bt.StatusId = 9 then 1 else 0 end) as 'Rejected',      
sum(case when bt.StatusId = 10 then 1 else 0 end) as 'Reply',      
sum(case when bt.StatusId = 11 then 1 else 0 end) as 'Duplicate',      
sum(case when bt.StatusId = 12 then 1 else 0 end) as 'UnConfirmed',    
COALESCE(sum(case when bt.StatusId = 1 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 2 then 1 else 0 end),0) +    
COALESCE(sum(case when bt.StatusId = 3 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 4 then 1 else 0 end),0) +    
COALESCE(sum(case when bt.StatusId = 5 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 6 then 1 else 0 end),0) +    
COALESCE(sum(case when bt.StatusId = 7 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 8 then 1 else 0 end),0) +    
COALESCE(sum(case when bt.StatusId = 9 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 10 then 1 else 0 end),0) +    
COALESCE(sum(case when bt.StatusId = 11 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 12 then 1 else 0 end),0) AS 'Total'  
from BugSummary bs      
inner join BugTracking bt on bs.BugId = bt.BugId      
inner join UserMaster UM on bt.AssignedTo = um.UserId      
where bs.ProjectId =@ProjectId       
GROUP BY um.FirstName +' '+um.LastName      
          
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetDeveloperTeamWiseStatusCount_Report]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetDeveloperTeamWiseStatusCount_Report]        
 @ProjectId int              
as            
begin            
            
select         
um.FirstName +' '+um.LastName as 'Developer',     
p.ProjectName AS 'Project',    
sum(case when bt.StatusId = 1 then 1 else 0 end) as 'Open',        
sum(case when bt.StatusId = 2 then 1 else 0 end) as 'Confirmed',        
sum(case when bt.StatusId = 3 then 1 else 0 end) as 'InProgress',        
sum(case when bt.StatusId = 4 then 1 else 0 end) as 'ReOpened',        
sum(case when bt.StatusId = 5 then 1 else 0 end) as 'Resolved',        
sum(case when bt.StatusId = 6 then 1 else 0 end) as 'InTesting',        
sum(case when bt.StatusId = 7 then 1 else 0 end) as 'Closed',        
sum(case when bt.StatusId = 8 then 1 else 0 end) as 'OnHold',        
sum(case when bt.StatusId = 9 then 1 else 0 end) as 'Rejected',        
sum(case when bt.StatusId = 10 then 1 else 0 end) as 'Reply',        
sum(case when bt.StatusId = 11 then 1 else 0 end) as 'Duplicate',        
sum(case when bt.StatusId = 12 then 1 else 0 end) as 'UnConfirmed'        
from BugSummary bs        
inner join BugTracking bt on bs.BugId = bt.BugId        
inner join UserMaster UM on bt.AssignedTo = um.UserId        
inner join dbo.Projects p on bs.ProjectId =p.ProjectId       
where bs.ProjectId =@ProjectId         
GROUP BY um.FirstName +' '+um.LastName ,p.ProjectName        
  ORDER BY p.ProjectName          
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetExternalReporterAssignedtoProject]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_GetExternalReporterAssignedtoProject]              
@ProjectId INT            
AS              
BEGIN              
              
SELECT CONVERT(VARCHAR(10),Ap.UserId) AS Value,              
UMR.FirstName +' '+ UMR.LastName as Text              
FROM dbo.AssignedProject Ap              
inner join UserMaster UMR on Ap.UserId = UMR.UserId                 
WHERE ap.RoleId = 8 AND AP.ProjectId =@ProjectId              
   order by UMR.FirstName asc           
end   
  
  
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetExternalReporterWiseStatusCount_Lead]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetExternalReporterWiseStatusCount_Lead]        
 @ProjectId int              
as            
begin            
            
select         
um.FirstName +' '+um.LastName as 'Names',         
sum(case when bt.StatusId = 1 then 1 else 0 end) as 'Open',        
sum(case when bt.StatusId = 2 then 1 else 0 end) as 'Confirmed',        
sum(case when bt.StatusId = 3 then 1 else 0 end) as 'InProgress',        
sum(case when bt.StatusId = 4 then 1 else 0 end) as 'ReOpened',        
sum(case when bt.StatusId = 5 then 1 else 0 end) as 'Resolved',        
sum(case when bt.StatusId = 6 then 1 else 0 end) as 'InTesting',        
sum(case when bt.StatusId = 7 then 1 else 0 end) as 'Closed',        
sum(case when bt.StatusId = 8 then 1 else 0 end) as 'OnHold',        
sum(case when bt.StatusId = 9 then 1 else 0 end) as 'Rejected',        
sum(case when bt.StatusId = 10 then 1 else 0 end) as 'Reply',        
sum(case when bt.StatusId = 11 then 1 else 0 end) as 'Duplicate',        
sum(case when bt.StatusId = 12 then 1 else 0 end) as 'UnConfirmed',      
COALESCE(sum(case when bt.StatusId = 1 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 2 then 1 else 0 end),0) +      
COALESCE(sum(case when bt.StatusId = 3 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 4 then 1 else 0 end),0) +      
COALESCE(sum(case when bt.StatusId = 5 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 6 then 1 else 0 end),0) +      
COALESCE(sum(case when bt.StatusId = 7 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 8 then 1 else 0 end),0) +      
COALESCE(sum(case when bt.StatusId = 9 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 10 then 1 else 0 end),0) +      
COALESCE(sum(case when bt.StatusId = 11 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 12 then 1 else 0 end),0) AS 'Total'    
from BugSummary bs        
inner join BugTracking bt on bs.BugId = bt.BugId        
inner join UserMaster UM on bt.CreatedBy = um.UserId        
where bs.ProjectId =@ProjectId    and bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId =8)         
GROUP BY um.FirstName +' '+um.LastName        
            
end 


     

GO
/****** Object:  StoredProcedure [dbo].[Usp_GetHardwareDetailsProjectWise]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE PROC [dbo].[Usp_GetHardwareDetailsProjectWise]  
@ProjectId int             
AS            
BEGIN            
            
    
SELECT COUNT(1) AS TotalCount, b.Hardware as TextValue  FROM dbo.BugSummary bs            
right JOIN dbo.Hardware b ON bs.HardwareId =b.HardwareId        
WHERE bs.ProjectId = @ProjectId         
GROUP BY b.HardwareId , b.Hardware            
          order by b.Hardware   asc
end            
            
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetNoticeforEditbyNoticeId]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_GetNoticeforEditbyNoticeId]
@NoticeId int
as
BEGIN
SELECT CONVERT(VARCHAR, N.NoticeStart, 121) AS NoticeStart,
       CONVERT(VARCHAR, N.NoticeEnd, 121) AS NoticeEnd,
	   N.NoticeTitle,
	   N.NoticeId,
	   ND.NoticeBody,
	   N.Status
FROM Notice N
    INNER JOIN NoticeDetails ND
        ON N.NoticeId = ND.NoticeId
WHERE N.NoticeId = @NoticeId
      AND N.Status = 1;
END
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetOpenandClosedCountbyUserId]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_GetOpenandClosedCountbyUserId]  
@UserId int  ,
@ProjectId int  
AS  
BEGIN  
  
SELECT SUM(CASE WHEN bt.StatusId =1 THEN 1 ELSE 0 END) AS 'Open',  
SUM(CASE WHEN bt.StatusId =7 THEN 1 ELSE 0 END) AS 'Closed'  
FROM dbo.BugTracking bt  
inner join BugSummary bs on bt.BugId = bs.BugId  
WHERE bt.CreatedBy =@UserId  and bs.ProjectId =  @ProjectId  
  
end  
  
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetOpenandClosedDevelopersBugsCountbyUserId]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_GetOpenandClosedDevelopersBugsCountbyUserId]    
@UserId int,
@ProjectId int
AS    
BEGIN    
    
SELECT SUM(CASE WHEN bt.StatusId =1 THEN 1 ELSE 0 END) AS 'Open',    
SUM(CASE WHEN bt.StatusId =7 THEN 1 ELSE 0 END) AS 'Closed'    
FROM dbo.BugTracking bt    
inner join BugSummary bs on bt.BugId = bs.BugId
WHERE bt.AssignedTo =@UserId  and bs.ProjectId =  @ProjectId
    
end    
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetOperatingSystemDetailsProjectWise]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE PROC [dbo].[Usp_GetOperatingSystemDetailsProjectWise]  
@ProjectId int             
AS            
BEGIN            
            
    
SELECT COUNT(1) AS TotalCount, os.OperatingSystemName as TextValue  FROM dbo.BugSummary bs            
right JOIN dbo.OperatingSystem os ON bs.OperatingSystemId =os.OperatingSystemId  
WHERE bs.ProjectId = @ProjectId         
GROUP BY os.OperatingSystemId , os.OperatingSystemName           
          order by os.OperatingSystemName asc 
end            
            
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetReporterTeamLeadBugsProjectwiseCount]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_GetReporterTeamLeadBugsProjectwiseCount]
@ProjectId int  
AS    
BEGIN    
    
SELECT COUNT(1) AS TotalCount, s.StatusName  FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bs.ProjectId = @ProjectId  
GROUP BY bt.StatusId, s.StatusName    
    
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetReporterTeamLeadOpenandClosedCount]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_GetReporterTeamLeadOpenandClosedCount]  
@ProjectId int    
AS    
BEGIN   
    
SELECT SUM(CASE WHEN bt.StatusId =1 THEN 1 ELSE 0 END) AS 'Open',    
SUM(CASE WHEN bt.StatusId =7 THEN 1 ELSE 0 END) AS 'Closed'    
FROM dbo.BugTracking bt    
inner join BugSummary bs on bt.BugId = bs.BugId    
WHERE bs.ProjectId =  @ProjectId    
    
end    
    
GO
/****** Object:  StoredProcedure [dbo].[USP_GetResetGeneratedToken]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[USP_GetResetGeneratedToken]  
 @UserId  bigint    
as  
begin  
select GeneratedToken from [ResetPasswordVerification] where UserId =@UserId and Status = 1 and VerificationStatus =0 order by ResetTokenId desc  
end  
  
  
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetSeverityProjectwiseCount_Developer]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetSeverityProjectwiseCount_Developer]
@UserId BIGINT,      
@ProjectId int      
as    
begin    
    
select count(1) as TotalCount ,s.Severity as TextValue from BugSummary bs    
inner join Severity s on bs.SeverityId = s.SeverityId    
inner join BugTracking bt on bt.BugId = bs.BugId 
WHERE bt.AssignedTo =@UserId  AND bs.ProjectId = @ProjectId     
GROUP BY bs.SeverityId, s.Severity        
        
end 

GO
/****** Object:  StoredProcedure [dbo].[Usp_GetSeverityProjectwiseCount_Lead]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetSeverityProjectwiseCount_Lead]        
@ProjectId int          
as        
begin        
        
select count(1) as TotalCount ,s.Severity as TextValue from BugSummary bs        
inner join Severity s on bs.SeverityId = s.SeverityId        
inner join BugTracking bt on bt.BugId = bs.BugId     
WHERE bs.ProjectId = @ProjectId         
GROUP BY bs.SeverityId, s.Severity       
order by s.Severity asc
      
            
end     
    
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetSeverityProjectwiseCount_Reporter]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetSeverityProjectwiseCount_Reporter]  
@UserId BIGINT,    
@ProjectId int    
as  
begin  
  
select count(1) as TotalCount ,s.Severity as TextValue from BugSummary bs  
inner join Severity s on bs.SeverityId = s.SeverityId  
WHERE bs.CreatedBy =@UserId  AND bs.ProjectId = @ProjectId   
GROUP BY bs.SeverityId, s.Severity      
      
end  
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetStarCommon]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_GetStarCommon]        
@ProjectId int,  
@RoleId int  
as          
        
begin        
   
   
Declare @FirstDate date        
Declare @LastDate date        
        
set @FirstDate = (SELECT CONVERT(date,DATEADD(DD,-(DAY(GETDATE() -1)), GETDATE())))         
set @LastDate = (SELECT CONVERT(date,DATEADD(DD,-(DAY(GETDATE())), DATEADD(MM, 1, GETDATE()))) )     

      if(@RoleId =9 or @RoleId = 10)  
begin    
SELECT top 3  COUNT(1) as TotalCount ,UM.FirstName+' '+UM.LastName as 'PerformerName'        
FROM dbo.BugTracking bt              
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId              
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId            
inner join UserMaster UM on bt.CreatedBy = UM.UserId                
WHERE  bs.ProjectId =@ProjectId and s.StatusId = 1 and CONVERT(date,bt.CreatedOn) between @FirstDate  and @LastDate   and    bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (9,10))   
group by UM.FirstName+' '+UM.LastName         
order by TotalCount desc        
      end  

	      if(@RoleId =11 or @RoleId = 12)  
begin    
SELECT top 3  COUNT(1) as TotalCount ,UM.FirstName+' '+UM.LastName as 'PerformerName'        
FROM dbo.BugTracking bt              
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId              
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId            
inner join UserMaster UM on bt.CreatedBy = UM.UserId                
WHERE  bs.ProjectId =@ProjectId and s.StatusId = 1 and CONVERT(date,bt.CreatedOn) between @FirstDate  and @LastDate   and    bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (11,12))   
group by UM.FirstName+' '+UM.LastName         
order by TotalCount desc        
      end  


end
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetStarDeveloper]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_GetStarDeveloper]    
@ProjectId int      
as      
    
begin    
    
Declare @FirstDate date    
Declare @LastDate date    
    
set @FirstDate = (SELECT CONVERT(date,DATEADD(DD,-(DAY(GETDATE() -1)), GETDATE())))     
set @LastDate = (SELECT CONVERT(date,DATEADD(DD,-(DAY(GETDATE())), DATEADD(MM, 1, GETDATE()))) )     
    
    
SELECT top 3 COUNT(1) as TotalCount ,UM.FirstName+' '+UM.LastName as 'PerformerName'    
FROM dbo.BugTracking bt          
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId          
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId        
inner join UserMaster UM on bt.AssignedTo = UM.UserId            
WHERE  bs.ProjectId =@ProjectId and s.StatusId = 7 and CONVERT(date,bt.ClosedOn) between @FirstDate  and @LastDate     
group by UM.FirstName+' '+UM.LastName     
order by TotalCount desc    
    
end
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetStarTester]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_GetStarTester]      
@ProjectId int        
as        
      
begin      
      
Declare @FirstDate date      
Declare @LastDate date      
      
set @FirstDate = (SELECT CONVERT(date,DATEADD(DD,-(DAY(GETDATE() -1)), GETDATE())))       
set @LastDate = (SELECT CONVERT(date,DATEADD(DD,-(DAY(GETDATE())), DATEADD(MM, 1, GETDATE()))) )       
      
SELECT top 3  COUNT(1) as TotalCount ,UM.FirstName+' '+UM.LastName as 'PerformerName'      
FROM dbo.BugTracking bt            
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId            
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId          
inner join UserMaster UM on bt.CreatedBy = UM.UserId              
WHERE  bs.ProjectId =@ProjectId and s.StatusId = 1 and CONVERT(date,bt.CreatedOn) between @FirstDate  and @LastDate 
and    bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (5,7))     
group by UM.FirstName+' '+UM.LastName       
order by TotalCount desc      
      
end
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetStatusWiseBugCount_Developers]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[Usp_GetStatusWiseBugCount_Developers]
@AssignedTo int,
@ProjectId int
as

begin
declare @OpenCount          int
declare @OpenValue          varchar(20)
declare @ConfirmedCount	  int
declare @ConfirmedValue          varchar(20)
declare @InProgressCount  int
declare @InProgressValue          varchar(20)
declare @ReOpenedCount	  int
declare @ReOpenedValue          varchar(20)
declare @ResolvedCount	  int
declare @ResolvedValue          varchar(20)
declare @InTestingCount	  int
declare @InTestingValue          varchar(20)
declare @ClosedCount		  int
declare @ClosedValue          varchar(20)
declare @OnHoldCount	  int
declare @OnHoldValue          varchar(20)
declare @RejectedCount	  int
declare @RejectedValue          varchar(20)
declare @ReplyCount		  int
declare @ReplyValue          varchar(20)
declare @DuplicateCount	  int
declare @DuplicateValue          varchar(20)
declare @UnConfirmedCount  int
declare @UnConfirmedValue          varchar(20)


SELECT @OpenCount = COUNT(1) , @OpenValue = 'Open'  FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.AssignedTo =@AssignedTo  AND bs.ProjectId =@ProjectId and s.StatusId = 1  
  
SELECT @ConfirmedCount = COUNT(1) , @ConfirmedValue ='Confirmed'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.AssignedTo =@AssignedTo  AND bs.ProjectId =@ProjectId and s.StatusId = 2 
 
SELECT @InProgressCount = COUNT(1) , @InProgressValue ='In-Progress'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.AssignedTo =@AssignedTo  AND bs.ProjectId =@ProjectId and s.StatusId = 3
 
SELECT @ReOpenedCount =COUNT(1) ,@ReOpenedValue = 'Re-Opened'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.AssignedTo =@AssignedTo  AND bs.ProjectId =@ProjectId and s.StatusId = 4  
 

SELECT @ResolvedCount =COUNT(1) , @ResolvedValue ='Resolved'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.AssignedTo =@AssignedTo  AND bs.ProjectId =@ProjectId and s.StatusId = 5  
 

SELECT @InTestingCount=COUNT(1) , @InTestingValue='InTesting'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.AssignedTo =@AssignedTo  AND bs.ProjectId =@ProjectId and s.StatusId = 6  
 

SELECT @ClosedCount =COUNT(1) ,@ClosedValue = 'Closed'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.AssignedTo =@AssignedTo  AND bs.ProjectId =@ProjectId and s.StatusId = 7 
 

SELECT @OnHoldCount =COUNT(1) , @OnHoldValue='On-Hold'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.AssignedTo =@AssignedTo  AND bs.ProjectId =@ProjectId and s.StatusId = 8  
 

SELECT @RejectedCount = COUNT(1) , @RejectedValue ='Rejected'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.AssignedTo =@AssignedTo  AND bs.ProjectId =@ProjectId and s.StatusId = 9  
 

SELECT @ReplyCount =COUNT(1) , @ReplyValue = 'Reply'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.AssignedTo =@AssignedTo  AND bs.ProjectId =@ProjectId and s.StatusId =10  
 

SELECT @DuplicateCount =COUNT(1) , @DuplicateValue ='Duplicate'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.AssignedTo =@AssignedTo  AND bs.ProjectId =@ProjectId and s.StatusId = 11 


SELECT @UnConfirmedCount = COUNT(1) , @UnConfirmedValue = 'UnConfirmed' 
FROM dbo.BugTracking bt    
right JOIN dbo.Status s ON bt.StatusId =s.StatusId    
right JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.AssignedTo =@AssignedTo  AND bs.ProjectId =@ProjectId and s.StatusId = 12  


select @OpenCount as OpenCount , @OpenValue as 'Open',      
 @ConfirmedCount  as ConfirmedCount, @ConfirmedValue as 'Confirmed'	 , 
 @InProgressCount as InProgress , @InProgressValue as 'InProgress',
 @ReOpenedCount	as ReOpenedCount ,@ReOpenedValue as 'ReOpened',
 @ResolvedCount	as ResolvedCount , @ResolvedValue as 'Resolved',
 @InTestingCount as InTestingCount	 , @InTestingValue as 'InTesting',
 @ClosedCount as ClosedCount	,	@ClosedValue as 'Closed',
 @OnHoldCount as OnHoldCount	 , @OnHoldValue as 'OnHold',
 @RejectedCount	as RejectedCount , @RejectedValue as 'Rejected',
 @ReplyCount as 	ReplyCount	 , @ReplyValue as  'Reply',
 @DuplicateCount as DuplicateCount	 , @DuplicateValue as 'Duplicate',
 @UnConfirmedCount as UnConfirmedCount ,@UnConfirmedValue as 'UnConfirmed'



End
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetStatusWiseBugCount_Lead]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[Usp_GetStatusWiseBugCount_Lead]
@ProjectId int
as

begin
declare @OpenCount          int
declare @OpenValue          varchar(20)
declare @ConfirmedCount	  int
declare @ConfirmedValue          varchar(20)
declare @InProgressCount  int
declare @InProgressValue          varchar(20)
declare @ReOpenedCount	  int
declare @ReOpenedValue          varchar(20)
declare @ResolvedCount	  int
declare @ResolvedValue          varchar(20)
declare @InTestingCount	  int
declare @InTestingValue          varchar(20)
declare @ClosedCount		  int
declare @ClosedValue          varchar(20)
declare @OnHoldCount	  int
declare @OnHoldValue          varchar(20)
declare @RejectedCount	  int
declare @RejectedValue          varchar(20)
declare @ReplyCount		  int
declare @ReplyValue          varchar(20)
declare @DuplicateCount	  int
declare @DuplicateValue          varchar(20)
declare @UnConfirmedCount  int
declare @UnConfirmedValue          varchar(20)


SELECT @OpenCount = COUNT(1) , @OpenValue = 'Open'  FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE  bs.ProjectId =@ProjectId and s.StatusId = 1  
  
SELECT @ConfirmedCount = COUNT(1) , @ConfirmedValue ='Confirmed'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE  bs.ProjectId =@ProjectId and s.StatusId = 2 
 
SELECT @InProgressCount = COUNT(1) , @InProgressValue ='In-Progress'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE  bs.ProjectId =@ProjectId and s.StatusId = 3
 
SELECT @ReOpenedCount =COUNT(1) ,@ReOpenedValue = 'Re-Opened'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE  bs.ProjectId =@ProjectId and s.StatusId = 4  
 

SELECT @ResolvedCount =COUNT(1) , @ResolvedValue ='Resolved'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE  bs.ProjectId =@ProjectId and s.StatusId = 5  
 

SELECT @InTestingCount=COUNT(1) , @InTestingValue='InTesting'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE  bs.ProjectId =@ProjectId and s.StatusId = 6  
 

SELECT @ClosedCount =COUNT(1) ,@ClosedValue = 'Closed'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE  bs.ProjectId =@ProjectId and s.StatusId = 7 
 

SELECT @OnHoldCount =COUNT(1) , @OnHoldValue='On-Hold'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE  bs.ProjectId =@ProjectId and s.StatusId = 8  
 

SELECT @RejectedCount = COUNT(1) , @RejectedValue ='Rejected'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE  bs.ProjectId =@ProjectId and s.StatusId = 9  
 

SELECT @ReplyCount =COUNT(1) , @ReplyValue = 'Reply'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE  bs.ProjectId =@ProjectId and s.StatusId =10  
 

SELECT @DuplicateCount =COUNT(1) , @DuplicateValue ='Duplicate'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE  bs.ProjectId =@ProjectId and s.StatusId = 11 


SELECT @UnConfirmedCount = COUNT(1) , @UnConfirmedValue = 'UnConfirmed' 
FROM dbo.BugTracking bt    
right JOIN dbo.Status s ON bt.StatusId =s.StatusId    
right JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE  bs.ProjectId =@ProjectId and s.StatusId = 12  


select @OpenCount as OpenCount , @OpenValue as 'Open',      
 @ConfirmedCount  as ConfirmedCount, @ConfirmedValue as 'Confirmed'	 , 
 @InProgressCount as InProgress , @InProgressValue as 'InProgress',
 @ReOpenedCount	as ReOpenedCount ,@ReOpenedValue as 'ReOpened',
 @ResolvedCount	as ResolvedCount , @ResolvedValue as 'Resolved',
 @InTestingCount as InTestingCount	 , @InTestingValue as 'InTesting',
 @ClosedCount as ClosedCount	,	@ClosedValue as 'Closed',
 @OnHoldCount as OnHoldCount	 , @OnHoldValue as 'OnHold',
 @RejectedCount	as RejectedCount , @RejectedValue as 'Rejected',
 @ReplyCount as 	ReplyCount	 , @ReplyValue as  'Reply',
 @DuplicateCount as DuplicateCount	 , @DuplicateValue as 'Duplicate',
 @UnConfirmedCount as UnConfirmedCount ,@UnConfirmedValue as 'UnConfirmed'



End
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetStatusWiseBugCount_Reporter]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_GetStatusWiseBugCount_Reporter]
@CreatedBy int,
@ProjectId int
as

begin
declare @OpenCount          int
declare @OpenValue          varchar(20)
declare @ConfirmedCount	  int
declare @ConfirmedValue          varchar(20)
declare @InProgressCount  int
declare @InProgressValue          varchar(20)
declare @ReOpenedCount	  int
declare @ReOpenedValue          varchar(20)
declare @ResolvedCount	  int
declare @ResolvedValue          varchar(20)
declare @InTestingCount	  int
declare @InTestingValue          varchar(20)
declare @ClosedCount		  int
declare @ClosedValue          varchar(20)
declare @OnHoldCount	  int
declare @OnHoldValue          varchar(20)
declare @RejectedCount	  int
declare @RejectedValue          varchar(20)
declare @ReplyCount		  int
declare @ReplyValue          varchar(20)
declare @DuplicateCount	  int
declare @DuplicateValue          varchar(20)
declare @UnConfirmedCount  int
declare @UnConfirmedValue          varchar(20)


SELECT @OpenCount = COUNT(1) , @OpenValue = 'Open'  FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.CreatedBy =@CreatedBy  AND bs.ProjectId =@ProjectId and s.StatusId = 1  
  
SELECT @ConfirmedCount = COUNT(1) , @ConfirmedValue ='Confirmed'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.CreatedBy =@CreatedBy  AND bs.ProjectId =@ProjectId and s.StatusId = 2 
 
SELECT @InProgressCount = COUNT(1) , @InProgressValue ='In-Progress'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.CreatedBy =@CreatedBy  AND bs.ProjectId =@ProjectId and s.StatusId = 3
 
SELECT @ReOpenedCount =COUNT(1) ,@ReOpenedValue = 'Re-Opened'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.CreatedBy =@CreatedBy  AND bs.ProjectId =@ProjectId and s.StatusId = 4  
 

SELECT @ResolvedCount =COUNT(1) , @ResolvedValue ='Resolved'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.CreatedBy =@CreatedBy  AND bs.ProjectId =@ProjectId and s.StatusId = 5  
 

SELECT @InTestingCount=COUNT(1) , @InTestingValue='InTesting'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.CreatedBy =@CreatedBy  AND bs.ProjectId =@ProjectId and s.StatusId = 6  
 

SELECT @ClosedCount =COUNT(1) ,@ClosedValue = 'Closed'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.CreatedBy =@CreatedBy  AND bs.ProjectId =@ProjectId and s.StatusId = 7 
 

SELECT @OnHoldCount =COUNT(1) , @OnHoldValue='On-Hold'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.CreatedBy =@CreatedBy  AND bs.ProjectId =@ProjectId and s.StatusId = 8  
 

SELECT @RejectedCount = COUNT(1) , @RejectedValue ='Rejected'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.CreatedBy =@CreatedBy  AND bs.ProjectId =@ProjectId and s.StatusId = 9  
 

SELECT @ReplyCount =COUNT(1) , @ReplyValue = 'Reply'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.CreatedBy =@CreatedBy  AND bs.ProjectId =@ProjectId and s.StatusId =10  
 

SELECT @DuplicateCount =COUNT(1) , @DuplicateValue ='Duplicate'   FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.CreatedBy =@CreatedBy  AND bs.ProjectId =@ProjectId and s.StatusId = 11 


SELECT @UnConfirmedCount = COUNT(1) , @UnConfirmedValue = 'UnConfirmed' 
FROM dbo.BugTracking bt    
right JOIN dbo.Status s ON bt.StatusId =s.StatusId    
right JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.CreatedBy =@CreatedBy  AND bs.ProjectId =@ProjectId and s.StatusId = 12  


select @OpenCount as OpenCount , @OpenValue as 'Open',      
 @ConfirmedCount  as ConfirmedCount, @ConfirmedValue as 'Confirmed'	 , 
 @InProgressCount as InProgress , @InProgressValue as 'InProgress',
 @ReOpenedCount	as ReOpenedCount ,@ReOpenedValue as 'ReOpened',
 @ResolvedCount	as ResolvedCount , @ResolvedValue as 'Resolved',
 @InTestingCount as InTestingCount	 , @InTestingValue as 'InTesting',
 @ClosedCount as ClosedCount	,	@ClosedValue as 'Closed',
 @OnHoldCount as OnHoldCount	 , @OnHoldValue as 'OnHold',
 @RejectedCount	as RejectedCount , @RejectedValue as 'Rejected',
 @ReplyCount as 	ReplyCount	 , @ReplyValue as  'Reply',
 @DuplicateCount as DuplicateCount	 , @DuplicateValue as 'Duplicate',
 @UnConfirmedCount as UnConfirmedCount ,@UnConfirmedValue as 'UnConfirmed'



End
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetSupportandTeamLeadAssignedtoProject]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_GetSupportandTeamLeadAssignedtoProject]          
@ProjectId INT        
AS          
BEGIN          
          
SELECT CONVERT(VARCHAR(10),Ap.UserId) AS Value,          
UMR.FirstName +' '+ UMR.LastName as Text          
FROM dbo.AssignedProject Ap          
inner join UserMaster UMR on Ap.UserId = UMR.UserId             
WHERE ap.RoleId IN (9,10) AND AP.ProjectId =@ProjectId          
   order by UMR.FirstName asc       
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetTestedEnvironmentProjectwiseCount_Developer]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetTestedEnvironmentProjectwiseCount_Developer]
@UserId BIGINT,    
@ProjectId int    
as  
begin  
  
select count(1) as TotalCount ,te.TestedOn as TextValue from BugSummary bs  
inner join TestedEnvironment te on bs.TestedOnId = te.TestedOnId  
inner join BugTracking bt on bt.BugId = bs.BugId
WHERE bt.AssignedTo =@UserId  AND bs.ProjectId = @ProjectId    
GROUP BY bs.TestedOnId, te.TestedOn  
  
end
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetTestedEnvironmentProjectwiseCount_Lead]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetTestedEnvironmentProjectwiseCount_Lead]  
      
@ProjectId int        
as      
begin      
      
select count(1) as TotalCount ,te.TestedOn as TextValue from BugSummary bs      
inner join TestedEnvironment te on bs.TestedOnId = te.TestedOnId      
inner join BugTracking bt on bt.BugId = bs.BugId    
WHERE bs.ProjectId = @ProjectId        
GROUP BY bs.TestedOnId, te.TestedOn      
      order by te.TestedOn asc
end  
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetTestedEnvironmentProjectwiseCount_Reporter]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetTestedEnvironmentProjectwiseCount_Reporter]
@UserId BIGINT,  
@ProjectId int  
as
begin

select count(1) as TotalCount ,te.TestedOn as TextValue from BugSummary bs
inner join TestedEnvironment te on bs.TestedOnId = te.TestedOnId
WHERE bs.CreatedBy =@UserId  AND bs.ProjectId = @ProjectId 
GROUP BY bs.TestedOnId, te.TestedOn

end
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetTesterBugOpenCloseDetails_Report]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


      
CREATE proc [dbo].[Usp_GetTesterBugOpenCloseDetails_Report]        
 @ProjectId int,      
 @Fromdate varchar(10),      
 @Todate varchar(10)      
as            
begin        
      
select bt.BugId ,       
CONVERT(varchar(10),bs.CreatedOn,103) as CreatedOn ,      
case when ISNULL(bt.ClosedOn,'') =''  then '---' else CONVERT(varchar(10),bt.ClosedOn,103) end as 'ClosedOn',      
UM.FirstName+' '+UM.LastName as 'Createdby',      
UMA.FirstName+' '+UMA.LastName as 'AssignedTo',        
bs.Summary,      
s.StatusName as 'Status',      
case when ISNULL(bt.ResolutionId,'') =''  then '---' else rs.Resolution end as 'Resolution'      
from BugTracking bt      
inner join BugSummary bs on bt.BugId = bs.BugId      
inner join UserMaster UM on bs.CreatedBy = UM.UserId      
inner join UserMaster UMA on bt.AssignedTo = UMA.UserId          
inner join Status S on bt.StatusId = s.StatusId      
left join Resolution rs on bt.ResolutionId = rs.ResolutionId      
where CONVERT(varchar(10),bs.CreatedOn,126)  between @Fromdate and @Todate and bs.ProjectId = @ProjectId      
 ORDER BY CONVERT(varchar(10),bs.CreatedOn,126) asc    
end
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetTestersandDevelopersAssignedtoProject]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_GetTestersandDevelopersAssignedtoProject]  
@ProjectId INT,  
@RoleId int  
AS  
BEGIN  
  
SELECT CONVERT(VARCHAR(10),Ap.UserId) AS Value,  
UMR.FirstName +' '+ UMR.LastName as Text  
FROM dbo.AssignedProject Ap  
inner join UserMaster UMR on Ap.UserId = UMR.UserId     
WHERE ap.RoleId = @RoleId AND AP.ProjectId =@ProjectId  
  
end  
  
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetTestersandTeamLeadAssignedtoProject]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_GetTestersandTeamLeadAssignedtoProject]        
@ProjectId INT      
AS        
BEGIN        
        
SELECT CONVERT(VARCHAR(10),Ap.UserId) AS Value,        
UMR.FirstName +' '+ UMR.LastName as Text        
FROM dbo.AssignedProject Ap        
inner join UserMaster UMR on Ap.UserId = UMR.UserId           
WHERE ap.RoleId IN (5,7,8) AND AP.ProjectId =@ProjectId        
   order by UMR.FirstName asc     
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetTesterTeamWiseProjectComponent_Report]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
-- exec Usp_GetTesterTeamWiseProjectComponent_Report 1        
CREATE proc [dbo].[Usp_GetTesterTeamWiseProjectComponent_Report]          
 @ProjectId int                
as              
begin              
              
select           
p.ProjectName as 'Project',        
PC.ComponentName as 'Component',        
um.FirstName +' '+um.LastName as 'Developer',           
sum(case when bt.StatusId = 1 then 1 else 0 end) as 'Open',          
sum(case when bt.StatusId = 2 then 1 else 0 end) as 'Confirmed',          
sum(case when bt.StatusId = 3 then 1 else 0 end) as 'InProgress',          
sum(case when bt.StatusId = 4 then 1 else 0 end) as 'ReOpened',          
sum(case when bt.StatusId = 5 then 1 else 0 end) as 'Resolved',          
sum(case when bt.StatusId = 6 then 1 else 0 end) as 'InTesting',          
sum(case when bt.StatusId = 7 then 1 else 0 end) as 'Closed',          
sum(case when bt.StatusId = 8 then 1 else 0 end) as 'OnHold',          
sum(case when bt.StatusId = 9 then 1 else 0 end) as 'Rejected',          
sum(case when bt.StatusId = 10 then 1 else 0 end) as 'Reply',          
sum(case when bt.StatusId = 11 then 1 else 0 end) as 'Duplicate',          
sum(case when bt.StatusId = 12 then 1 else 0 end) as 'UnConfirmed'          
from BugSummary bs          
inner join BugTracking bt on bs.BugId = bt.BugId          
inner join UserMaster UM on bt.CreatedBy = um.UserId          
inner join Projects p on bs.ProjectId = p.ProjectId         
inner join ProjectComponent PC on bs.ProjectComponentId = pc.ProjectComponentId        
where bs.ProjectId =@ProjectId           
GROUP BY p.ProjectName,PC.ComponentName,um.FirstName +' '+um.LastName          
   ORDER BY p.ProjectName,PC.ComponentName,um.FirstName +' '+um.LastName  asc               
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetTesterTeamWiseStatusCount_Lead]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetTesterTeamWiseStatusCount_Lead]        
 @ProjectId int              
as            
begin            
            
select         
um.FirstName +' '+um.LastName as 'Names',         
sum(case when bt.StatusId = 1 then 1 else 0 end) as 'Open',        
sum(case when bt.StatusId = 2 then 1 else 0 end) as 'Confirmed',        
sum(case when bt.StatusId = 3 then 1 else 0 end) as 'InProgress',        
sum(case when bt.StatusId = 4 then 1 else 0 end) as 'ReOpened',        
sum(case when bt.StatusId = 5 then 1 else 0 end) as 'Resolved',        
sum(case when bt.StatusId = 6 then 1 else 0 end) as 'InTesting',        
sum(case when bt.StatusId = 7 then 1 else 0 end) as 'Closed',        
sum(case when bt.StatusId = 8 then 1 else 0 end) as 'OnHold',        
sum(case when bt.StatusId = 9 then 1 else 0 end) as 'Rejected',        
sum(case when bt.StatusId = 10 then 1 else 0 end) as 'Reply',        
sum(case when bt.StatusId = 11 then 1 else 0 end) as 'Duplicate',        
sum(case when bt.StatusId = 12 then 1 else 0 end) as 'UnConfirmed',      
COALESCE(sum(case when bt.StatusId = 1 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 2 then 1 else 0 end),0) +      
COALESCE(sum(case when bt.StatusId = 3 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 4 then 1 else 0 end),0) +      
COALESCE(sum(case when bt.StatusId = 5 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 6 then 1 else 0 end),0) +      
COALESCE(sum(case when bt.StatusId = 7 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 8 then 1 else 0 end),0) +      
COALESCE(sum(case when bt.StatusId = 9 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 10 then 1 else 0 end),0) +      
COALESCE(sum(case when bt.StatusId = 11 then 1 else 0 end),0) + COALESCE(sum(case when bt.StatusId = 12 then 1 else 0 end),0) AS 'Total'    
from BugSummary bs        
inner join BugTracking bt on bs.BugId = bt.BugId        
inner join UserMaster UM on bt.CreatedBy = um.UserId        
where bs.ProjectId =@ProjectId  and bs.CreatedBy in (select UserId from AssignedProject where ProjectId =@ProjectId and RoleId in (5,7))                  
GROUP BY um.FirstName +' '+um.LastName        
            
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetTesterTeamWiseStatusCount_Report]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
CREATE proc [dbo].[Usp_GetTesterTeamWiseStatusCount_Report]      
 @ProjectId int                  
as      
      
begin      
      
select             
um.FirstName +' '+um.LastName as 'Tester',         
p.ProjectName AS 'Project',        
sum(case when bt.StatusId = 1 then 1 else 0 end) as 'Open',            
sum(case when bt.StatusId = 2 then 1 else 0 end) as 'Confirmed',            
sum(case when bt.StatusId = 3 then 1 else 0 end) as 'InProgress',            
sum(case when bt.StatusId = 4 then 1 else 0 end) as 'ReOpened',            
sum(case when bt.StatusId = 5 then 1 else 0 end) as 'Resolved',            
sum(case when bt.StatusId = 6 then 1 else 0 end) as 'InTesting',            
sum(case when bt.StatusId = 7 then 1 else 0 end) as 'Closed',            
sum(case when bt.StatusId = 8 then 1 else 0 end) as 'OnHold',            
sum(case when bt.StatusId = 9 then 1 else 0 end) as 'Rejected',            
sum(case when bt.StatusId = 10 then 1 else 0 end) as 'Reply',            
sum(case when bt.StatusId = 11 then 1 else 0 end) as 'Duplicate',            
sum(case when bt.StatusId = 12 then 1 else 0 end) as 'UnConfirmed'            
from BugSummary bs            
inner join BugTracking bt on bs.BugId = bt.BugId            
inner join UserMaster um on bt.CreatedBy = um.UserId            
inner join dbo.Projects p on bs.ProjectId =p.ProjectId           
where bs.ProjectId =@ProjectId             
GROUP BY  p.ProjectName   ,       um.FirstName +' '+um.LastName  
  ORDER BY p.ProjectName  , um.FirstName +' '+um.LastName asc  
end
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetTimeTakeReport]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[Usp_GetTimeTakeReport]
@ProjectId int
as

begin

select 
P.ProjectName,
dbo.fn_GetDaysAndTimeFromDate(bt.CreatedOn,bt.ClosedOn) as Timetaken,
UM.FirstName+' '+UM.LastName as 'Createdby',        
UMA.FirstName+' '+UMA.LastName as 'AssignedTo', 
bs.Summary,        
s.StatusName as 'Status' ,
case when ISNULL(bt.ResolutionId,'') =''  then '---' else rs.Resolution end as 'Resolution',
CONVERT(varchar(10),bs.CreatedOn,103) as CreatedOn ,        
case when ISNULL(bt.ClosedOn,'') =''  then '---' else CONVERT(varchar(10),bt.ClosedOn,103) end as 'ClosedOn'
from BugTracking bt
inner join BugSummary bs on bt.BugId = bs.BugId        
inner join UserMaster UM on bs.CreatedBy = UM.UserId        
inner join UserMaster UMA on bt.AssignedTo = UMA.UserId            
inner join Status S on bt.StatusId = s.StatusId        
left join Resolution rs on bt.ResolutionId = rs.ResolutionId   
inner join Projects P on bs.ProjectId = p.ProjectId

where bs.ProjectId = @ProjectId
end

--Usp_GetTimeTakeReport 1
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetTotalBugStatusCountProjectWise]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Usp_GetTotalBugStatusCountProjectWise]  
 @ProjectId int        
as      
begin   

select     
sum(case when bt.StatusId = 1 then 1 else 0 end) as 'Open',  
sum(case when bt.StatusId = 2 then 1 else 0 end) as 'Confirmed',  
sum(case when bt.StatusId = 3 then 1 else 0 end) as 'InProgress',  
sum(case when bt.StatusId = 4 then 1 else 0 end) as 'ReOpened',  
sum(case when bt.StatusId = 5 then 1 else 0 end) as 'Resolved',  
sum(case when bt.StatusId = 6 then 1 else 0 end) as 'InTesting',  
sum(case when bt.StatusId = 7 then 1 else 0 end) as 'Closed',  
sum(case when bt.StatusId = 8 then 1 else 0 end) as 'OnHold',  
sum(case when bt.StatusId = 9 then 1 else 0 end) as 'Rejected',  
sum(case when bt.StatusId = 10 then 1 else 0 end) as 'Reply',  
sum(case when bt.StatusId = 11 then 1 else 0 end) as 'Duplicate',  
sum(case when bt.StatusId = 12 then 1 else 0 end) as 'UnConfirmed'  
from BugSummary bs  
inner join BugTracking bt on bs.BugId = bt.BugId  
where bs.ProjectId =@ProjectId

end
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetUserDetailforProfilebyUserId]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_GetUserDetailforProfilebyUserId]  
@UserId int  
AS  
  
BEGIN  
  
SELECT um.FirstName +' '+ um.LastName AS FullName ,dm.Designation,um.EmailId , um.MobileNo ,   
CONVERT(varchar,um.IsFirstLoginDate,107) AS FirstLoginDate ,um.Gender FROM dbo.UserMaster um  
INNER JOIN dbo.DesignationMaster dm ON um.DesignationId = dm.DesignationId  
WHERE um.UserId = @UserId  
  
end  
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetUserLoggedActivity]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[Usp_GetUserLoggedActivity]

@UserID int

as
begin

SELECT top 20 convert(varchar, CurrentDatetime, 107) as CurrentDate ,convert(varchar, LoggedInAt, 0) as LoggedInAt,convert(varchar, LoggedOutAt, 0) as LoggedOutAt
  FROM [dbo].[Audit] 
  where 
     UserID =@UserID and Logged=1
	 order by AuditId desc

end
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetUserNamesWithoutSpecificUser]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_GetUserNamesWithoutSpecificUser]    
@Username varchar(10),    
@UserId int,    
@RoleId int    
as    
begin    
    
if(@RoleId = 4 or @RoleId = 6 )    
begin    
select U.FirstName +' '+U.LastName as Text, U.UserId  as Value from UserMaster u    
inner join SavedAssignedRoles sar on u.UserId = sar.UserId    
where FirstName like '%'+ @Username +'%' and u.UserId != @UserId and RoleId in (4,6)    
end    
    
if(@RoleId = 5 or @RoleId = 7 )    
begin    
select U.FirstName +' '+U.LastName as Text, U.UserId  as Value from UserMaster u    
inner join SavedAssignedRoles sar on u.UserId = sar.UserId    
where FirstName like '%'+ @Username +'%' and u.UserId != @UserId and RoleId in (5,7)    
end    
if(@RoleId = 8  )    
begin    
select U.FirstName +' '+U.LastName as Text, U.UserId  as Value from UserMaster u    
inner join SavedAssignedRoles sar on u.UserId = sar.UserId    
where FirstName like '%'+ @Username +'%' and u.UserId != @UserId and RoleId in (8)    
end    
 
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetVersionDetailsProjectWise]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
create PROC [dbo].[Usp_GetVersionDetailsProjectWise]
@ProjectId int           
AS          
BEGIN          
          
  
SELECT COUNT(1) AS TotalCount, b.VersionName as TextValue  FROM dbo.BugSummary bs          
right JOIN dbo.Version b ON bs.VersionId =b.VersionId      
WHERE bs.ProjectId = @ProjectId       
GROUP BY b.VersionId , b.VersionName          
        
end          
          
GO
/****** Object:  StoredProcedure [dbo].[Usp_GetWebFrameworkDetailsProjectWise]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
  
    
CREATE PROC [dbo].[Usp_GetWebFrameworkDetailsProjectWise]  
@ProjectId int             
AS            
BEGIN            
            
    
SELECT COUNT(1) AS TotalCount, wf.WebFramework as TextValue  FROM dbo.BugSummary bs            
right JOIN dbo.WebFrameworks wf ON bs.WebFrameworkId =wf.WebFrameworkId  
WHERE bs.ProjectId = @ProjectId         
GROUP BY wf.WebFrameworkId, wf.WebFramework           
    order by wf.WebFramework asc          
end            
            
GO
/****** Object:  StoredProcedure [dbo].[Usp_InsertBugHistory]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_InsertBugHistory]
 @MESSAGE varchar(100)
,@ProcessDate datetime
,@UserId bigint
,@BugId bigint
,@StatusId int
,@PriorityId int
,@AssignedTo bigint
AS
begin


INSERT INTO [dbo].[BugHistory]
           ([Message]
           ,[ProcessDate]
           ,[UserId]
           ,[BugId]
           ,[StatusId]
           ,[PriorityId]
           ,[AssignedTo])
     VALUES
           (@MESSAGE 
           ,@ProcessDate 
           ,@UserId 
           ,@BugId 
           ,@StatusId 
           ,@PriorityId 
           ,@AssignedTo)
end


GO
/****** Object:  StoredProcedure [dbo].[USP_InsertResetPasswordVerificationToken]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[USP_InsertResetPasswordVerificationToken]  
 @UserId  bigint    
,@GeneratedToken  varchar(70)    
,@GeneratedDate  datetime    
as  
begin  
INSERT INTO [dbo].[ResetPasswordVerification]  
           ([UserId]  
           ,[GeneratedToken]  
           ,[GeneratedDate]  
           ,[Status]  
           ,[VerificationStatus]  
           ,[VerificationDate])  
     VALUES  
           (@UserId      
           ,@GeneratedToken    
           ,@GeneratedDate      
           ,1      
           ,0   
           ,NULL )  
end  
  
  
GO
/****** Object:  StoredProcedure [dbo].[Usp_MyBugListGrid]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_MyBugListGrid]            
@AssignedTo bigint,            
@ProjectId int = null,            
@PriorityId int= null,            
@SeverityId int= null,            
@StatusId int = null,            
@ProjectComponentId int = null,            
@page INT,            
@pageSize INT            
as            
begin            
            
            
DECLARE @SQLQuery AS NVARCHAR(max)            
set @SQLQuery = ''            
SET @SQLQuery = @SQLQuery + '            
SELECT * FROM            
(             
            
select ROW_NUMBER() OVER (ORDER BY BS.BugId desc) as RowNum,            
BS.BugId ,            
BS.Summary ,            
P.ProjectName ,            
PC.ComponentName,            
pr.PriorityName,            
case when ISNULL(RS.ResolutionId,0) =0 then ''NA'' else rs.Resolution end as Resolution,            
s.Severity,            
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,            
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,            
UM.FirstName +'' ''+ SUBSTRING(UM.LastName, 1, 1)  as AssignedTo,              
ST.StatusName,          
ST.StatusId,    
CONVERT(varchar(10),bt.ClosedOn,126) as ClosedOn,
TE.TestedOn,
TE.TestedOnId
from BugSummary BS            
inner join BugTracking bt on BS.BugId = bt.BugId            
inner join Projects p on BS.ProjectId = p.ProjectId            
inner join Severity S on BS.SeverityId = S.SeverityId            
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId            
inner join Priority pr on BS.PriorityId = pr.PriorityId            
left join Resolution RS on bt.ResolutionId = RS.ResolutionId            
inner join UserMaster UM on Bt.AssignedTo = UM.UserId             
inner join Status St on Bt.StatusId = St.StatusId 
inner join TestedEnvironment TE on BS.TestedOnId = TE.TestedOnId
where bt.AssignedTo = '''+ convert(VARCHAR(10),@AssignedTo) + ''''            
            
if(@ProjectId is not null and @ProjectId>0)            
 begin            
 SET @SQLQuery = @SQLQuery + '             
  and  BS.ProjectId = ' + convert(VARCHAR(50),@ProjectId) + ' '              
 end             
            
if(@PriorityId is not null and @PriorityId>0)            
 begin            
 SET @SQLQuery = @SQLQuery + '             
  and  BS.PriorityId = ' + convert(VARCHAR(50),@PriorityId) + ' '              
 end             
            
 if(@SeverityId is not null and @SeverityId>0)            
 begin            
 SET @SQLQuery = @SQLQuery + '             
  and  BS.SeverityId = ' + convert(VARCHAR(50),@SeverityId) + ' '              
 end             
            
 if(@StatusId is not null and @StatusId>0)            
 begin            
 SET @SQLQuery = @SQLQuery + '             
  and  Bt.StatusId = ' + convert(VARCHAR(50),@StatusId) + ' '              
 end             
             
 if(@ProjectComponentId is not null and @ProjectComponentId>0)            
 begin            
 SET @SQLQuery = @SQLQuery + '             
  and  BS.ProjectComponentId = ' + convert(VARCHAR(50),@ProjectComponentId) + ' '              
 end             
             
SET @SQLQuery = @SQLQuery + '  ) A            
WHERE A.RowNum            
BETWEEN (((' + convert(VARCHAR(10),@page) + ' - 1) * ' + convert(VARCHAR(10),@pageSize) + ') + 1) AND (' + convert(VARCHAR(10),@page) + ' * ' + convert(VARCHAR(10),@pageSize) + ')            
ORDER BY A.RowNum;'            
            
print @SQLQuery            
EXEC (@SQLQuery)            
            
            
end   
GO
/****** Object:  StoredProcedure [dbo].[Usp_MyBugListGrid_LastSevenDays]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_MyBugListGrid_LastSevenDays]                  
@AssignedTo bigint,                             
@page INT,                  
@pageSize INT                  
as                  
begin                  
     
 declare @lastweek datetime    
declare @now datetime    
set @now = getdate()    
set @lastweek = dateadd(day,-7,@now)         
                  
DECLARE @SQLQuery AS NVARCHAR(max)                  
set @SQLQuery = ''                  
SET @SQLQuery = @SQLQuery + '                  
SELECT * FROM                  
(                   
                  
select ROW_NUMBER() OVER (ORDER BY BS.BugId desc) as RowNum,                  
BS.BugId ,                  
BS.Summary ,                  
P.ProjectName ,                  
PC.ComponentName,                  
pr.PriorityName,                  
case when ISNULL(RS.ResolutionId,0) =0 then ''NA'' else rs.Resolution end as Resolution,                  
s.Severity,                  
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,                  
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,                  
UM.FirstName +'' ''+ SUBSTRING(UM.LastName, 1, 1)  as AssignedTo,                    
ST.StatusName,                
ST.StatusId,          
CONVERT(varchar(10),bt.ClosedOn,126) as ClosedOn          
from BugSummary BS                  
inner join BugTracking bt on BS.BugId = bt.BugId                  
inner join Projects p on BS.ProjectId = p.ProjectId                  
inner join Severity S on BS.SeverityId = S.SeverityId                  
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                  
inner join Priority pr on BS.PriorityId = pr.PriorityId                  
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                  
inner join UserMaster UM on Bt.AssignedTo = UM.UserId                   
inner join Status St on Bt.StatusId = St.StatusId                   
where bt.AssignedTo = '''+ convert(VARCHAR(10),@AssignedTo) + ''''                  
    
SET @SQLQuery = @SQLQuery + 'and  convert(VARCHAR(10),isnull(bt.ModifiedOn,bt.CreatedOn),23) >=  '''+ convert(VARCHAR(10),@lastweek,23) + ''''           
                            
                   
SET @SQLQuery = @SQLQuery + '  ) A                  
WHERE A.RowNum                  
BETWEEN (((' + convert(VARCHAR(10),@page) + ' - 1) * ' + convert(VARCHAR(10),@pageSize) + ') + 1) AND (' + convert(VARCHAR(10),@page) + ' * ' + convert(VARCHAR(10),@pageSize) + ')                  
ORDER BY A.RowNum;'                  
                  
print @SQLQuery                  
EXEC (@SQLQuery)                  
                  
                  
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_MyBugListGridCount]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Usp_MyBugListGrid 9,1,'','','','',1,10


CREATE Proc [dbo].[Usp_MyBugListGridCount]  
@AssignedTo bigint,  
@ProjectId int = null,  
@PriorityId int= null,  
@SeverityId int= null,  
@StatusId int = null,  
@ProjectComponentId int = null  
as  
begin  
  
  
DECLARE @SQLQuery AS NVARCHAR(max)  
set @SQLQuery = ''  
SET @SQLQuery = @SQLQuery + '  
  
select  count(1) as ctn  
from BugSummary BS  
inner join BugTracking bt on BS.BugId = bt.BugId  
inner join Projects p on BS.ProjectId = p.ProjectId  
inner join Severity S on BS.SeverityId = S.SeverityId  
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId  
inner join Priority pr on BS.PriorityId = pr.PriorityId  
left join Resolution RS on bt.ResolutionId = RS.ResolutionId  
inner join UserMaster UM on Bt.AssignedTo = UM.UserId   
inner join Status St on Bt.StatusId = St.StatusId   
where bt.AssignedTo = '''+ convert(VARCHAR(10),@AssignedTo) + ''''  
  
if(@ProjectId is not null and @ProjectId>0)  
 begin  
 SET @SQLQuery = @SQLQuery + '   
  and  BS.ProjectId = ' + convert(VARCHAR(50),@ProjectId) + ' '    
 end   
  
if(@PriorityId is not null and @PriorityId>0)  
 begin  
 SET @SQLQuery = @SQLQuery + '   
  and  BS.PriorityId = ' + convert(VARCHAR(50),@PriorityId) + ' '    
 end   
  
 if(@SeverityId is not null and @SeverityId>0)  
 begin  
 SET @SQLQuery = @SQLQuery + '   
  and  BS.SeverityId = ' + convert(VARCHAR(50),@SeverityId) + ' '    
 end   
  
 if(@StatusId is not null and @StatusId>0)  
 begin  
 SET @SQLQuery = @SQLQuery + '   
  and  Bt.StatusId = ' + convert(VARCHAR(50),@StatusId) + ' '    
 end   
  
 if(@ProjectComponentId is not null and @ProjectComponentId>0)  
 begin  
 SET @SQLQuery = @SQLQuery + '   
  and  BS.ProjectComponentId = ' + convert(VARCHAR(50),@ProjectComponentId) + ' '    
 end   
   
SET @SQLQuery = @SQLQuery + ' '  
  
print @SQLQuery  
EXEC (@SQLQuery)  
  
  
end  
  
--- exec Usp_BugListGridCount 6,1,1,3,1,1,10
GO
/****** Object:  StoredProcedure [dbo].[Usp_MyBugListGridCount_LastSevenDays]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Usp_MyBugListGrid_LastSevenDays 9,1,'','','','',1,10      
      
      
CREATE Proc [dbo].[Usp_MyBugListGridCount_LastSevenDays]        
@AssignedTo bigint       
as        
begin        
        
    
declare @lastweek datetime    
declare @now datetime    
set @now = getdate()    
set @lastweek = dateadd(day,-7,@now)         
        
DECLARE @SQLQuery AS NVARCHAR(max)        
set @SQLQuery = ''        
SET @SQLQuery = @SQLQuery + '        
        
select  count(1) as ctn        
from BugSummary BS        
inner join BugTracking bt on BS.BugId = bt.BugId        
inner join Projects p on BS.ProjectId = p.ProjectId        
inner join Severity S on BS.SeverityId = S.SeverityId        
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId        
inner join Priority pr on BS.PriorityId = pr.PriorityId        
left join Resolution RS on bt.ResolutionId = RS.ResolutionId        
inner join UserMaster UM on Bt.AssignedTo = UM.UserId         
inner join Status St on Bt.StatusId = St.StatusId         
where bt.AssignedTo = '''+ convert(VARCHAR(10),@AssignedTo) + ''''        
    
SET @SQLQuery = @SQLQuery + 'and  convert(VARCHAR(10),isnull(bt.ModifiedOn,bt.CreatedOn),23) >=  '''+ convert(VARCHAR(10),@lastweek,23) + ''''              
              
SET @SQLQuery = @SQLQuery + ' '        
        
print @SQLQuery        
EXEC (@SQLQuery)        
        
        
end        
        
GO
/****** Object:  StoredProcedure [dbo].[Usp_MyBusinessAnalystBugListGridCount_LastSevenDays]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[Usp_MyBusinessAnalystBugListGridCount_LastSevenDays]                     
   @UserId INT                     
as                    
begin                    
                    
declare @lastweek datetime            
declare @now datetime            
set @now = getdate()            
set @lastweek = dateadd(day,-7,@now)                 
            
DECLARE @SQLQuery AS NVARCHAR(max)                    
set @SQLQuery = ''                    
SET @SQLQuery = @SQLQuery + '                    
                    
select  count(1) as ctn                    
from BugSummary BS                    
inner join BugTracking bt on BS.BugId = bt.BugId                    
inner join Projects p on BS.ProjectId = p.ProjectId                    
inner join Severity S on BS.SeverityId = S.SeverityId                    
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                    
inner join Priority pr on BS.PriorityId = pr.PriorityId                    
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                    
inner join UserMaster UM on Bt.AssignedTo = UM.UserId                     
inner join Status St on Bt.StatusId = St.StatusId where 1=1'                    
             
SET @SQLQuery = @SQLQuery + 'and  convert(VARCHAR(10),isnull(bt.ModifiedOn,bt.CreatedOn),23) >=  '''+ convert(VARCHAR(10),@lastweek,23) + ''''                   
            
IF(@UserId is not null and @UserId>0)                              
 begin                              
 SET @SQLQuery = @SQLQuery + '  and BS.CreatedBy in (select UserId from AssignedProject where RoleId in (11,12))'      
                          
 end          
                        
                 
SET @SQLQuery = @SQLQuery + ' '                    
                    
print @SQLQuery                    
EXEC (@SQLQuery)                    
                    
                    
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_MyManagerBugCount]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_MyManagerBugCount]                        
@StatusId int = null,          
@ProjectId int = null,        
@ProjectComponentId int = null,        
@SeverityId int= null,           
@PriorityId int= null,                    
@VersionId int= null,              
@OperatingSystemId int= null,         
@HardwareId int= null,        
@BrowserId int= null,        
@WebFrameworkId int= null,        
@TestedOnId int= null,        
@BugTypeId int= null,        
@ReportersUserId INT    = null,     
@DevelopersUserId INT    = null,  
@SupportUserId INT    = null,     
@BussinessUserId INT    = null,    
@ExternalUserId INT    = null        
as                    
begin                    
                    
                    
DECLARE @SQLQuery AS NVARCHAR(max)                    
set @SQLQuery = ''                    
SET @SQLQuery = @SQLQuery + '                    
select  count(1) as ctn       
from BugSummary BS                    
inner join BugTracking bt on BS.BugId = bt.BugId                    
inner join Projects p on BS.ProjectId = p.ProjectId                    
inner join Severity S on BS.SeverityId = S.SeverityId                    
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                    
inner join Priority pr on BS.PriorityId = pr.PriorityId                    
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                    
inner join UserMaster UM on Bt.AssignedTo = UM.UserId             
inner join UserMaster UMR on BS.CreatedBy = UMR.UserId              
inner join Status St on Bt.StatusId = St.StatusId where 1=1 '                    
    
 if(@StatusId is not null and @StatusId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  Bt.StatusId = ' + convert(VARCHAR(50),@StatusId) + ' '                      
 end       
     
if(@ProjectId is not null and @ProjectId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.ProjectId = ' + convert(VARCHAR(50),@ProjectId) + ' '                      
 end                     
     
  if(@ProjectComponentId is not null and @ProjectComponentId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.ProjectComponentId = ' + convert(VARCHAR(50),@ProjectComponentId) + ' '                      
 end       
    
  if(@SeverityId is not null and @SeverityId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.SeverityId = ' + convert(VARCHAR(50),@SeverityId) + ' '                      
 end              
    
if(@PriorityId is not null and @PriorityId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.PriorityId = ' + convert(VARCHAR(50),@PriorityId) + ' '                      
 end                     
                    
 if(@VersionId is not null and @VersionId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.VersionId = ' + convert(VARCHAR(50),@VersionId) + ' '                      
 end                     
                    
 if(@OperatingSystemId is not null and @OperatingSystemId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.OperatingSystemId = ' + convert(VARCHAR(50),@OperatingSystemId) + ' '                      
 end                     
                               
  if(@HardwareId is not null and @HardwareId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.HardwareId = ' + convert(VARCHAR(50),@HardwareId) + ' '                      
 end          
     
  if(@BrowserId is not null and @BrowserId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.BrowserId = ' + convert(VARCHAR(50),@BrowserId) + ' '                      
 end                                      
                     
   if(@WebFrameworkId is not null and @WebFrameworkId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.WebFrameworkId = ' + convert(VARCHAR(50),@WebFrameworkId) + ' '        
 end                            
                              
   if(@TestedOnId is not null and @TestedOnId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.TestedOnId = ' + convert(VARCHAR(50),@TestedOnId) + ' '                      
 end                            
             
 if(@BugTypeId is not null and @BugTypeId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.BugTypeId = ' + convert(VARCHAR(50),@BugTypeId) + ' '                      
 end                            
    
IF(@ReportersUserId is not null and @ReportersUserId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.CreatedBy = ' + convert(VARCHAR(50),@ReportersUserId) + ' '                      
 end       
     
 IF(@DevelopersUserId is not null and @DevelopersUserId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  bt.AssignedTo = ' + convert(VARCHAR(50),@DevelopersUserId) + ' '                      
 end          
   
      
 IF(@SupportUserId is not null and @SupportUserId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  bt.CreatedBy = ' + convert(VARCHAR(50),@SupportUserId) + ' '                      
 end        
  
      
 IF(@BussinessUserId is not null and @BussinessUserId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  bt.CreatedBy = ' + convert(VARCHAR(50),@BussinessUserId) + ' '                      
 end        
   
 IF(@ExternalUserId is not null and @ExternalUserId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  bt.CreatedBy = ' + convert(VARCHAR(50),@ExternalUserId) + ' '                      
 end        

  
SET @SQLQuery = @SQLQuery + ' '                   
                    
print @SQLQuery                    
EXEC (@SQLQuery)                    
                    
                    
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_MyManagerBugListGrid]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_MyManagerBugListGrid]                            
@StatusId int = null,              
@ProjectId int = null,            
@ProjectComponentId int = null,            
@SeverityId int= null,               
@PriorityId int= null,                        
@VersionId int= null,                  
@OperatingSystemId int= null,             
@HardwareId int= null,            
@BrowserId int= null,            
@WebFrameworkId int= null,            
@TestedOnId int= null,            
@BugTypeId int= null,            
@ReportersUserId INT    = null,         
@DevelopersUserId INT    = null,        
@SupportUserId INT    = null,     
@BussinessUserId INT    = null,    
@page INT,                        
@pageSize INT,
@ExternalUserId INT    = null        
        
as                        
begin                        
                        
                        
DECLARE @SQLQuery AS NVARCHAR(max)                        
set @SQLQuery = ''                        
SET @SQLQuery = @SQLQuery + '                        
SELECT * FROM                        
(                         
                        
select ROW_NUMBER() OVER (ORDER BY BS.BugId desc) as RowNum,                        
BS.BugId ,                        
BS.Summary ,                        
P.ProjectName ,                        
PC.ComponentName,                        
pr.PriorityName,                        
case when ISNULL(RS.ResolutionId,0) =0 then ''NA'' else rs.Resolution end as Resolution,                        
s.Severity,                        
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,                        
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,                        
UM.FirstName +'' ''+ SUBSTRING(UM.LastName, 1, 1)  as AssignedTo,           
UMR.FirstName +'' ''+ SUBSTRING(UMR.LastName, 1, 1) as Reportedby,      
ST.StatusName,                      
ST.StatusId,          
CONVERT(varchar(10),bt.ClosedOn,126) as ClosedOn,
TE.TestedOn,
TE.TestedOnId
from BugSummary BS                        
inner join BugTracking bt on BS.BugId = bt.BugId                        
inner join Projects p on BS.ProjectId = p.ProjectId                        
inner join Severity S on BS.SeverityId = S.SeverityId                        
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                        
inner join Priority pr on BS.PriorityId = pr.PriorityId                        
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                        
inner join UserMaster UM on Bt.AssignedTo = UM.UserId                 
inner join UserMaster UMR on BS.CreatedBy = UMR.UserId      
inner join Status St on Bt.StatusId = St.StatusId
inner join TestedEnvironment TE on BS.TestedOnId = TE.TestedOnId'                        
        
 if(@StatusId is not null and @StatusId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  Bt.StatusId = ' + convert(VARCHAR(50),@StatusId) + ' '                          
 end           
         
if(@ProjectId is not null and @ProjectId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  BS.ProjectId = ' + convert(VARCHAR(50),@ProjectId) + ' '                          
 end                         
         
  if(@ProjectComponentId is not null and @ProjectComponentId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  BS.ProjectComponentId = ' + convert(VARCHAR(50),@ProjectComponentId) + ' '                          
 end           
        
  if(@SeverityId is not null and @SeverityId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  BS.SeverityId = ' + convert(VARCHAR(50),@SeverityId) + ' '                          
 end                  
        
if(@PriorityId is not null and @PriorityId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  BS.PriorityId = ' + convert(VARCHAR(50),@PriorityId) + ' '                        
 end                         
                        
 if(@VersionId is not null and @VersionId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '        
  and  BS.VersionId = ' + convert(VARCHAR(50),@VersionId) + ' '                          
 end                         
                        
 if(@OperatingSystemId is not null and @OperatingSystemId>0)                        
 begin                     
 SET @SQLQuery = @SQLQuery + '                         
  and  BS.OperatingSystemId = ' + convert(VARCHAR(50),@OperatingSystemId) + ' '                          
 end            
                                   
  if(@HardwareId is not null and @HardwareId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  BS.HardwareId = ' + convert(VARCHAR(50),@HardwareId) + ' '                          
 end              
         
  if(@BrowserId is not null and @BrowserId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  BS.BrowserId = ' + convert(VARCHAR(50),@BrowserId) + ' '                          
 end                                          
                                   
   if(@WebFrameworkId is not null and @WebFrameworkId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  BS.WebFrameworkId = ' + convert(VARCHAR(50),@WebFrameworkId) + ' '                          
 end                                
                                  
   if(@TestedOnId is not null and @TestedOnId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  BS.TestedOnId = ' + convert(VARCHAR(50),@TestedOnId) + ' '                          
 end                                
                 
 if(@BugTypeId is not null and @BugTypeId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  BS.BugTypeId = ' + convert(VARCHAR(50),@BugTypeId) + ' '                          
 end                                
        
IF(@ReportersUserId is not null and @ReportersUserId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  BS.CreatedBy = ' + convert(VARCHAR(50),@ReportersUserId) + ' '                          
 end           
         
 IF(@DevelopersUserId is not null and @DevelopersUserId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  bt.AssignedTo = ' + convert(VARCHAR(50),@DevelopersUserId) + ' '                          
 end              
    
        
 IF(@SupportUserId is not null and @SupportUserId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  bt.CreatedBy = ' + convert(VARCHAR(50),@SupportUserId) + ' '                      
 end        
  
      
 IF(@BussinessUserId is not null and @BussinessUserId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  bt.CreatedBy = ' + convert(VARCHAR(50),@BussinessUserId) + ' '                      
 end        
   
   
 IF(@ExternalUserId is not null and @ExternalUserId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  bt.CreatedBy = ' + convert(VARCHAR(50),@ExternalUserId) + ' '                      
 end        

  
SET @SQLQuery = @SQLQuery + '  ) A                        
WHERE A.RowNum                        
BETWEEN (((' + convert(VARCHAR(10),@page) + ' - 1) * ' + convert(VARCHAR(10),@pageSize) + ') + 1) AND (' + convert(VARCHAR(10),@page) + ' * ' + convert(VARCHAR(10),@pageSize) + ')                        
ORDER BY A.RowNum;'                        
                        
print @SQLQuery                        
EXEC (@SQLQuery)                        
                        
                        
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_MyReportersBugListGrid]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_MyReportersBugListGrid]                            
@ProjectId int = null,                        
@PriorityId int= null,                        
@SeverityId int= null,                        
@StatusId int = null,                        
@ProjectComponentId int = null,                        
@page INT,                        
@pageSize INT,            
@ReportersUserId INT            
as                        
begin                        
                        
                        
DECLARE @SQLQuery AS NVARCHAR(max)                        
set @SQLQuery = ''                        
SET @SQLQuery = @SQLQuery + '                        
SELECT * FROM                        
(                         
                        
select ROW_NUMBER() OVER (ORDER BY BS.BugId desc) as RowNum,                        
BS.BugId ,                        
BS.Summary ,                        
P.ProjectName ,                        
PC.ComponentName,                        
pr.PriorityName,                        
case when ISNULL(RS.ResolutionId,0) =0 then ''NA'' else rs.Resolution end as Resolution,                        
s.Severity,                        
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,                        
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,                        
UM.FirstName +'' ''+ SUBSTRING(UM.LastName, 1, 1) as AssignedTo,              
UMR.FirstName +'' ''+ SUBSTRING(UMR.LastName, 1, 1) as Reportedby,               
ST.StatusName,                      
ST.StatusId,          
CONVERT(varchar(10),bt.ClosedOn,126) as ClosedOn,
TE.TestedOn,
TE.TestedOnId
from BugSummary BS                        
inner join BugTracking bt on BS.BugId = bt.BugId                        
inner join Projects p on BS.ProjectId = p.ProjectId                        
inner join Severity S on BS.SeverityId = S.SeverityId                        
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                        
inner join Priority pr on BS.PriorityId = pr.PriorityId                        
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                        
inner join UserMaster UM on Bt.AssignedTo = UM.UserId                 
inner join UserMaster UMR on bt.CreatedBy = UMR.UserId                  
inner join Status St on Bt.StatusId = St.StatusId
inner join TestedEnvironment TE on BS.TestedOnId = TE.TestedOnId
where bt.CreatedBy in (select UserId from AssignedProject where ProjectId = '''+ convert(VARCHAR(10),@ProjectId) + '''and RoleId in (5,7))'
                        
if(@ProjectId is not null and @ProjectId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  BS.ProjectId = ' + convert(VARCHAR(50),@ProjectId) + ' '                          
 end                         
                        
if(@PriorityId is not null and @PriorityId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  BS.PriorityId = ' + convert(VARCHAR(50),@PriorityId) + ' '                          
 end                         
                        
 if(@SeverityId is not null and @SeverityId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  BS.SeverityId = ' + convert(VARCHAR(50),@SeverityId) + ' '                          
 end                         
                        
 if(@StatusId is not null and @StatusId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  Bt.StatusId = ' + convert(VARCHAR(50),@StatusId) + ' '                          
 end                         
                         
 if(@ProjectComponentId is not null and @ProjectComponentId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  BS.ProjectComponentId = ' + convert(VARCHAR(50),@ProjectComponentId) + ' '                          
 end                         
            
IF(@ReportersUserId is not null and @ReportersUserId>0)                        
 begin                        
 SET @SQLQuery = @SQLQuery + '                         
  and  bt.CreatedBy = ' + convert(VARCHAR(50),@ReportersUserId) + ' '                          
 end               
             
SET @SQLQuery = @SQLQuery + '  ) A                        
WHERE A.RowNum                        
BETWEEN (((' + convert(VARCHAR(10),@page) + ' - 1) * ' + convert(VARCHAR(10),@pageSize) + ') + 1) AND (' + convert(VARCHAR(10),@page) + ' * ' + convert(VARCHAR(10),@pageSize) + ')                        
ORDER BY A.RowNum;'                        
                        
print @SQLQuery                        
EXEC (@SQLQuery)                        
                        
                        
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_MyReportersBugListGrid_LastSevenDays]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_MyReportersBugListGrid_LastSevenDays]                                      
                              
@page INT,                                  
@pageSize INT,                     
@UserId INT                      
as                                  
begin                                  
            
 declare @lastweek datetime          
declare @now datetime          
set @now = getdate()          
set @lastweek = dateadd(day,-7,@now)                                 
                                  
DECLARE @SQLQuery AS NVARCHAR(max)                                  
set @SQLQuery = ''                                  
SET @SQLQuery = @SQLQuery + '                                  
SELECT * FROM                                  
(                                   
                                  
select ROW_NUMBER() OVER (ORDER BY BS.BugId desc) as RowNum,                                  
BS.BugId ,                                  
BS.Summary ,                                  
P.ProjectName ,                                  
PC.ComponentName,                                  
pr.PriorityName,                                  
case when ISNULL(RS.ResolutionId,0) =0 then ''NA'' else rs.Resolution end as Resolution,                                  
s.Severity,                                  
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,                                  
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,                                  
UM.FirstName +'' ''+ SUBSTRING(UM.LastName, 1, 1) as AssignedTo,                        
UMR.FirstName +'' ''+ SUBSTRING(UMR.LastName, 1, 1) as Reportedby,                         
ST.StatusName,                                
ST.StatusId,                    
CONVERT(varchar(10),bt.ClosedOn,126) as ClosedOn                    
from BugSummary BS                                  
inner join BugTracking bt on BS.BugId = bt.BugId                                  
inner join Projects p on BS.ProjectId = p.ProjectId                                  
inner join Severity S on BS.SeverityId = S.SeverityId                                  
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                                  
inner join Priority pr on BS.PriorityId = pr.PriorityId                                  
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                                  
inner join UserMaster UM on Bt.AssignedTo = UM.UserId                           
inner join UserMaster UMR on bt.CreatedBy = UMR.UserId                            
inner join Status St on Bt.StatusId = St.StatusId where 1=1'                                  
           
SET @SQLQuery = @SQLQuery + 'and  convert(VARCHAR(10),isnull(bt.ModifiedOn,bt.CreatedOn),23) >=  '''+ convert(VARCHAR(10),@lastweek,23) + ''''              
        
      
               
 IF(@UserId is not null and @UserId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  bs.ProjectId in (select ProjectId from AssignedProject where UserId = ' + convert(VARCHAR(50),@UserId) + ') '                      
 end 
 
  IF(@UserId is not null and @UserId>0)                                
 begin                                
 SET @SQLQuery = @SQLQuery + '  and BS.CreatedBy in (select UserId from AssignedProject where RoleId in (5,7))'        
                            
 end     
        
  
SET @SQLQuery = @SQLQuery + '  ) A                                  
WHERE A.RowNum                                  
BETWEEN (((' + convert(VARCHAR(10),@page) + ' - 1) * ' + convert(VARCHAR(10),@pageSize) + ') + 1) AND (' + convert(VARCHAR(10),@page) + ' * ' + convert(VARCHAR(10),@pageSize) + ')                                  
ORDER BY A.RowNum;'                                  
                                  
print @SQLQuery                                  
EXEC (@SQLQuery)                                  
                                  
                                  
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_MyReportersBugListGridCount]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_MyReportersBugListGridCount]         
@ProjectId int = null,        
@PriorityId int= null,        
@SeverityId int= null,        
@StatusId int = null,        
@ProjectComponentId int = NULL,    
@ReportersUserId INT    
as        
begin        
        
        
DECLARE @SQLQuery AS NVARCHAR(max)        
set @SQLQuery = ''        
SET @SQLQuery = @SQLQuery + '        
        
select  count(1) as ctn        
from BugSummary BS        
inner join BugTracking bt on BS.BugId = bt.BugId        
inner join Projects p on BS.ProjectId = p.ProjectId        
inner join Severity S on BS.SeverityId = S.SeverityId        
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId        
inner join Priority pr on BS.PriorityId = pr.PriorityId        
left join Resolution RS on bt.ResolutionId = RS.ResolutionId        
inner join UserMaster UM on Bt.AssignedTo = UM.UserId         
inner join Status St on Bt.StatusId = St.StatusId
where bt.CreatedBy in (select UserId from AssignedProject where ProjectId = '''+ convert(VARCHAR(10),@ProjectId) + '''and RoleId in (5,7))'
        
if(@ProjectId is not null and @ProjectId>0)        
 begin        
 SET @SQLQuery = @SQLQuery + '         
  and  BS.ProjectId = ' + convert(VARCHAR(50),@ProjectId) + ' '          
 end         
        
if(@PriorityId is not null and @PriorityId>0)        
 begin        
 SET @SQLQuery = @SQLQuery + '         
  and  BS.PriorityId = ' + convert(VARCHAR(50),@PriorityId) + ' '          
 end         
        
 if(@SeverityId is not null and @SeverityId>0)        
 begin        
 SET @SQLQuery = @SQLQuery + '         
  and  BS.SeverityId = ' + convert(VARCHAR(50),@SeverityId) + ' '          
 end         
        
 if(@StatusId is not null and @StatusId>0)        
 begin        
 SET @SQLQuery = @SQLQuery + '         
  and  Bt.StatusId = ' + convert(VARCHAR(50),@StatusId) + ' '          
 end         
        
 if(@ProjectComponentId is not null and @ProjectComponentId>0)        
 begin        
 SET @SQLQuery = @SQLQuery + '         
  and  BS.ProjectComponentId = ' + convert(VARCHAR(50),@ProjectComponentId) + ' '          
 end         
    
 IF(@ReportersUserId is not null and @ReportersUserId>0)                
 begin                
 SET @SQLQuery = @SQLQuery + '                 
  and  bt.CreatedBy = ' + convert(VARCHAR(50),@ReportersUserId) + ' '                  
 end          
     
SET @SQLQuery = @SQLQuery + ' '        
        
print @SQLQuery        
EXEC (@SQLQuery)        
        
        
end        
        
--- exec Usp_BugListGridCount 6,1,1,3,1,1,10  
GO
/****** Object:  StoredProcedure [dbo].[Usp_MyReportersBugListGridCount_LastSevenDays]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_MyReportersBugListGridCount_LastSevenDays]                       
   @UserId INT                       
as                      
begin                      
                      
declare @lastweek datetime              
declare @now datetime              
set @now = getdate()              
set @lastweek = dateadd(day,-7,@now)                   
              
DECLARE @SQLQuery AS NVARCHAR(max)                      
set @SQLQuery = ''                      
SET @SQLQuery = @SQLQuery + '                      
                      
select  count(1) as ctn                      
from BugSummary BS                      
inner join BugTracking bt on BS.BugId = bt.BugId                      
inner join Projects p on BS.ProjectId = p.ProjectId                      
inner join Severity S on BS.SeverityId = S.SeverityId                      
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                      
inner join Priority pr on BS.PriorityId = pr.PriorityId                      
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                      
inner join UserMaster UM on Bt.AssignedTo = UM.UserId                       
inner join Status St on Bt.StatusId = St.StatusId where 1=1'                      
               
SET @SQLQuery = @SQLQuery + 'and  convert(VARCHAR(10),isnull(bt.ModifiedOn,bt.CreatedOn),23) >=  '''+ convert(VARCHAR(10),@lastweek,23) + ''''                     
              
 IF(@UserId is not null and @UserId>0)                        
 begin                        
SET @SQLQuery = @SQLQuery + '                       
  and  bs.ProjectId in (select ProjectId from AssignedProject where UserId = ' + convert(VARCHAR(50),@UserId) + ') '       
               
 end             
  
  IF(@UserId is not null and @UserId>0)                                
 begin                                
 SET @SQLQuery = @SQLQuery + '  and BS.CreatedBy in (select UserId from AssignedProject where RoleId in (5,7))'        
                            
 end                          
                   
SET @SQLQuery = @SQLQuery + ' '                      
                      
print @SQLQuery                      
EXEC (@SQLQuery)                      
                      
                      
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_MyTeamsBugListGrid]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_MyTeamsBugListGrid]                            
@ProjectId int = null,                  
@PriorityId int= null,                  
@SeverityId int= null,                  
@StatusId int = null,                  
@ProjectComponentId int = null,                  
@page INT,                  
@pageSize INT ,      
@DevUserId INT        
as                  
begin                  
                  
                  
DECLARE @SQLQuery AS NVARCHAR(max)                  
set @SQLQuery = ''                  
SET @SQLQuery = @SQLQuery + '                  
SELECT * FROM                  
(                   
                  
select ROW_NUMBER() OVER (ORDER BY BS.BugId desc) as RowNum,                  
BS.BugId ,                  
BS.Summary ,                  
P.ProjectName ,                  
PC.ComponentName,                  
pr.PriorityName,                  
case when ISNULL(RS.ResolutionId,0) =0 then ''NA'' else rs.Resolution end as Resolution,                  
s.Severity,                  
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,                  
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,                  
UM.FirstName +'' ''+ SUBSTRING(UM.LastName, 1, 1)  as AssignedTo,         
UMR.FirstName +'' ''+ SUBSTRING(UMR.LastName, 1, 1)as Reportedby,             
ST.StatusName,                
ST.StatusId,        
CONVERT(varchar(10),bt.ClosedOn,126) as ClosedOn,
TE.TestedOn,
TE.TestedOnId
from BugSummary BS                  
inner join BugTracking bt on BS.BugId = bt.BugId                  
inner join Projects p on BS.ProjectId = p.ProjectId                  
inner join Severity S on BS.SeverityId = S.SeverityId                  
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                  
inner join Priority pr on BS.PriorityId = pr.PriorityId                  
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                  
inner join UserMaster UM on Bt.AssignedTo = UM.UserId            
inner join UserMaster UMR on BS.CreatedBy = UMR.UserId           
inner join Status St on Bt.StatusId = St.StatusId
inner join TestedEnvironment TE on BS.TestedOnId = TE.TestedOnId'                  
                  
if(@ProjectId is not null and @ProjectId>0)                  
 begin                  
 SET @SQLQuery = @SQLQuery + '                   
  and  BS.ProjectId = ' + convert(VARCHAR(50),@ProjectId) + ' '                    
 end                   
                  
if(@PriorityId is not null and @PriorityId>0)                  
 begin                  
 SET @SQLQuery = @SQLQuery + '                   
  and  BS.PriorityId = ' + convert(VARCHAR(50),@PriorityId) + ' '                    
 end                   
                  
 if(@SeverityId is not null and @SeverityId>0)                  
 begin                  
 SET @SQLQuery = @SQLQuery + '                   
  and  BS.SeverityId = ' + convert(VARCHAR(50),@SeverityId) + ' '                    
 end                   
                  
 if(@StatusId is not null and @StatusId>0)                  
 begin                  
 SET @SQLQuery = @SQLQuery + '                   
  and  Bt.StatusId = ' + convert(VARCHAR(50),@StatusId) + ' '                    
 end                   
                   
 if(@ProjectComponentId is not null and @ProjectComponentId>0)                  
 begin                  
 SET @SQLQuery = @SQLQuery + '                   
  and  BS.ProjectComponentId = ' + convert(VARCHAR(50),@ProjectComponentId) + ' '                    
 end                
       
 IF(@DevUserId is not null and @DevUserId>0)                  
 begin                  
 SET @SQLQuery = @SQLQuery + '                   
  and  bt.AssignedTo = ' + convert(VARCHAR(50),@DevUserId) + ' '                    
 end        
       
SET @SQLQuery = @SQLQuery + '  ) A                  
WHERE A.RowNum                  
BETWEEN (((' + convert(VARCHAR(10),@page) + ' - 1) * ' + convert(VARCHAR(10),@pageSize) + ') + 1) AND (' + convert(VARCHAR(10),@page) + ' * ' + convert(VARCHAR(10),@pageSize) + ')                  
ORDER BY A.RowNum;'                  
   
print @SQLQuery                  
EXEC (@SQLQuery)                  
                  
                  
end     
GO
/****** Object:  StoredProcedure [dbo].[Usp_MyTeamsBugListGrid_LastSevenDays]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from UserMaster

--update UserMaster
--set UserMaster.PasswordHash ='b6bc7b58510319a151d168ba3d5aecb3ac0a9708d06dd930f37fbc89b6cdc697'
--where UserId = 15

--- exec Usp_MyTeamsBugListGrid_LastSevenDays 1,10,10        
        
CREATE Proc [dbo].[Usp_MyTeamsBugListGrid_LastSevenDays]                                               
@page INT,                      
@pageSize INT,  
@DevUserId INT     
as                      
begin         
  
DECLARE @lastweek DATETIME    
DECLARE @now datetime    
set @now = getdate()    
set @lastweek = dateadd(day,-7,@now)                         
                      
DECLARE @SQLQuery AS NVARCHAR(max)                      
set @SQLQuery = ''                      
SET @SQLQuery = @SQLQuery + '                      
SELECT * FROM                      
(                       
                      
select ROW_NUMBER() OVER (ORDER BY BS.BugId desc) as RowNum,                      
BS.BugId ,                      
BS.Summary ,                      
P.ProjectName ,                      
PC.ComponentName,                      
pr.PriorityName,                      
case when ISNULL(RS.ResolutionId,0) =0 then ''NA'' else rs.Resolution end as Resolution,                      
s.Severity,                      
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,                      
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,                      
UM.FirstName +'' ''+ SUBSTRING(UM.LastName, 1, 1)  as AssignedTo,             
UMR.FirstName +'' ''+ SUBSTRING(UMR.LastName, 1, 1)as Reportedby,                 
ST.StatusName,                    
ST.StatusId,            
CONVERT(varchar(10),bt.ClosedOn,126) as ClosedOn            
from BugSummary BS                      
inner join BugTracking bt on BS.BugId = bt.BugId                      
inner join Projects p on BS.ProjectId = p.ProjectId                      
inner join Severity S on BS.SeverityId = S.SeverityId                      
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                      
inner join Priority pr on BS.PriorityId = pr.PriorityId                      
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                      
inner join UserMaster UM on Bt.AssignedTo = UM.UserId                
inner join UserMaster UMR on BS.CreatedBy = UMR.UserId               
inner join Status St on Bt.StatusId = St.StatusId where 1=1'                      
    
    
SET @SQLQuery = @SQLQuery + 'and  convert(VARCHAR(10),isnull(bt.ModifiedOn,bt.CreatedOn),23) >=  '''+ convert(VARCHAR(10),@lastweek,23) + ''''           
   
 IF(@DevUserId is not null and @DevUserId>0)                  
 begin                  
 SET @SQLQuery = @SQLQuery + '                   
  and  bs.ProjectId in (select ProjectId from AssignedProject where UserId = ' + convert(VARCHAR(50),@DevUserId) + ') '                    
 end       
         
			  

SET @SQLQuery = @SQLQuery + '  ) A                      
WHERE A.RowNum                      
BETWEEN (((' + convert(VARCHAR(10),@page) + ' - 1) * ' + convert(VARCHAR(10),@pageSize) + ') + 1) AND (' + convert(VARCHAR(10),@page) + ' * ' + convert(VARCHAR(10),@pageSize) + ')                      
ORDER BY A.RowNum;'                      
       
print @SQLQuery                      
EXEC (@SQLQuery)                      
                      
                      
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_MyTeamsBugListGridCount]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--- exec Usp_MyTeamsBugListGridCount 6,1,1,3,1,1,10  
  
CREATE Proc [dbo].[Usp_MyTeamsBugListGridCount]      
@ProjectId int = null,      
@PriorityId int= null,      
@SeverityId int= null,      
@StatusId int = null,      
@ProjectComponentId int = NULL,
@DevUserId INT  
as      
begin      
      
      
DECLARE @SQLQuery AS NVARCHAR(max)      
set @SQLQuery = ''      
SET @SQLQuery = @SQLQuery + '      
      
select  count(1) as ctn      
from BugSummary BS      
inner join BugTracking bt on BS.BugId = bt.BugId      
inner join Projects p on BS.ProjectId = p.ProjectId      
inner join Severity S on BS.SeverityId = S.SeverityId      
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId      
inner join Priority pr on BS.PriorityId = pr.PriorityId      
left join Resolution RS on bt.ResolutionId = RS.ResolutionId      
inner join UserMaster UM on Bt.AssignedTo = UM.UserId       
inner join Status St on Bt.StatusId = St.StatusId'      
      
if(@ProjectId is not null and @ProjectId>0)      
 begin      
 SET @SQLQuery = @SQLQuery + '       
  and  BS.ProjectId = ' + convert(VARCHAR(50),@ProjectId) + ' '        
 end       
      
if(@PriorityId is not null and @PriorityId>0)      
 begin      
 SET @SQLQuery = @SQLQuery + '       
  and  BS.PriorityId = ' + convert(VARCHAR(50),@PriorityId) + ' '        
 end       
      
 if(@SeverityId is not null and @SeverityId>0)      
 begin      
 SET @SQLQuery = @SQLQuery + '       
  and  BS.SeverityId = ' + convert(VARCHAR(50),@SeverityId) + ' '        
 end       
      
 if(@StatusId is not null and @StatusId>0)      
 begin      
 SET @SQLQuery = @SQLQuery + '       
  and  Bt.StatusId = ' + convert(VARCHAR(50),@StatusId) + ' '        
 end       
      
 if(@ProjectComponentId is not null and @ProjectComponentId>0)      
 begin      
 SET @SQLQuery = @SQLQuery + '       
  and  BS.ProjectComponentId = ' + convert(VARCHAR(50),@ProjectComponentId) + ' '        
 end       
  IF(@DevUserId is not null and @DevUserId>0)            
 begin            
 SET @SQLQuery = @SQLQuery + '             
  and  bt.AssignedTo = ' + convert(VARCHAR(50),@DevUserId) + ' '              
 end        
SET @SQLQuery = @SQLQuery + ' '      
      
print @SQLQuery      
EXEC (@SQLQuery)      
      
      
end      
      
GO
/****** Object:  StoredProcedure [dbo].[Usp_MyTeamsBugListGridCount_LastSevenDays]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
CREATE Proc [dbo].[Usp_MyTeamsBugListGridCount_LastSevenDays]            
   
@DevUserId INT        
as            
begin            
      
DECLARE @lastweek DATETIME    
DECLARE @now datetime    
set @now = getdate()    
set @lastweek = dateadd(day,-7,@now)               
            
DECLARE @SQLQuery AS NVARCHAR(max)            
set @SQLQuery = ''            
SET @SQLQuery = @SQLQuery + '            
            
select  count(1) as ctn            
from BugSummary BS            
inner join BugTracking bt on BS.BugId = bt.BugId            
inner join Projects p on BS.ProjectId = p.ProjectId            
inner join Severity S on BS.SeverityId = S.SeverityId            
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId            
inner join Priority pr on BS.PriorityId = pr.PriorityId            
left join Resolution RS on bt.ResolutionId = RS.ResolutionId            
inner join UserMaster UM on Bt.AssignedTo = UM.UserId             
inner join Status St on Bt.StatusId = St.StatusId where 1=1'            
     
SET @SQLQuery = @SQLQuery + 'and  convert(VARCHAR(10),isnull(bt.ModifiedOn,bt.CreatedOn),23) >=  '''+ convert(VARCHAR(10),@lastweek,23) + ''''     
    
   
 IF(@DevUserId is not null and @DevUserId>0)                  
 begin                  
 SET @SQLQuery = @SQLQuery + '                   
  and  bs.ProjectId in (select ProjectId from AssignedProject where UserId = ' + convert(VARCHAR(50),@DevUserId) + ') '                    
 end       
                     
SET @SQLQuery = @SQLQuery + ' '            
            
print @SQLQuery            
EXEC (@SQLQuery)            
            
            
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_PasswordMaster_UpdatePassword]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_PasswordMaster_UpdatePassword]    
    @UserId BIGINT,    
    @PasswordHash VARCHAR(300),    
    @ProcessType VARCHAR(1)    
AS    
BEGIN    
     
    if(@ProcessType = 'F')
	begin

	   UPDATE UserMaster    
        SET UserMaster.IsFirstLogin=0,    
            UserMaster.IsFirstLoginDate = GETDATE() 
        WHERE UserMaster.UserId = @UserId;    

	end


	 if(@ProcessType = 'C')
	begin

	   DECLARE @OldPasswordHash VARCHAR(64);    
     
  
        SET @OldPasswordHash =    
        (    
            SELECT TOP (1)    
                   PasswordHash    
            FROM UserMaster  
            WHERE UserId = @UserId    
            ORDER BY UserId    
        );    
         
   
        INSERT INTO [dbo].[PasswordHistory]    
        (    
            [PasswordHash],    
            [CreatedDate],    
            [UserId],    
            [ProcessType]    
        )    
        VALUES    
        (@OldPasswordHash, GETDATE(), @UserId, @ProcessType);    
    
    
       
        UPDATE UserMaster    
        SET UserMaster.PasswordHash = @PasswordHash,    
            UserMaster.ModifiedOn = GETDATE()  ,  
   UserMaster.ModifiedBy =@UserId  
        WHERE UserMaster.UserId = @UserId;    

	end
    
     
    
    
END; 
GO
/****** Object:  StoredProcedure [dbo].[Usp_ReporterLeadPieChartData]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Usp_ReporterLeadPieChartData]   
@ProjectId int  
AS    
BEGIN    
    
SELECT COUNT(1) AS TotalCount, s.StatusName  FROM dbo.BugTracking bt    
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId    
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId    
WHERE bs.ProjectId = @ProjectId   
GROUP BY bt.StatusId, s.StatusName    
    
end    
    
    
    
    
GO
/****** Object:  StoredProcedure [dbo].[Usp_ReporterPieChartData]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_ReporterPieChartData]  
@UserId int,
@ProjectId int
AS  
BEGIN  
  
SELECT COUNT(1) AS TotalCount, s.StatusName  FROM dbo.BugTracking bt  
INNER JOIN dbo.Status s ON bt.StatusId =s.StatusId  
INNER JOIN dbo.BugSummary bs ON bt.BugId =bs.BugId  
WHERE bt.CreatedBy =@UserId and bs.ProjectId = @ProjectId 
GROUP BY bt.StatusId, s.StatusName  
  
end  
  
  
  
  
  
GO
/****** Object:  StoredProcedure [dbo].[Usp_ReporterPriorityPieChartData]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_ReporterPriorityPieChartData]    
@UserId bigint    
AS    
BEGIN    
    
SELECT COUNT(1) AS TotalCount, p.PriorityName  FROM dbo.BugSummary bs    
right JOIN dbo.Priority p ON bs.PriorityId =p.PriorityId  
WHERE bs.CreatedBy =@UserId    
GROUP BY p.PriorityId, p.PriorityName     
  
end    
    
    
    
    
GO
/****** Object:  StoredProcedure [dbo].[Usp_ReporterTeamLeadPriorityPieChartData]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_ReporterTeamLeadPriorityPieChartData]      
@ProjectId int       
AS      
BEGIN      
      
SELECT COUNT(1) AS TotalCount, p.PriorityName  FROM dbo.BugSummary bs      
right JOIN dbo.Priority p ON bs.PriorityId =p.PriorityId    
WHERE bs.ProjectId = @ProjectId   
GROUP BY p.PriorityId, p.PriorityName       
    
end      
      
      
      
GO
/****** Object:  StoredProcedure [dbo].[Usp_ShowNotice]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_ShowNotice]

AS
BEGIN

SELECT N.NoticeId
      ,N.NoticeTitle
	  ,ND.NoticeBody
	  ,N.NoticeStart
	  ,N.NoticeEnd
	  ,
	FORMAT (N.CreatedOn, 'dddd, MMMM, yyyy') as CreatedOn
  FROM Notice N
  INNER JOIN NoticeDetails ND ON  N.NoticeId =ND.NoticeId
  WHERE N.NoticeStart >= GETDATE() or GETDATE() <= N.NoticeEnd AND N.Status = 1

END
GO
/****** Object:  StoredProcedure [dbo].[Usp_SMTPEmailSettings_SetDefault]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_SMTPEmailSettings_SetDefault] 
@SmtpProviderId INT  
AS  
BEGIN  
 UPDATE SMTPEmailSettings  
 SET SMTPEmailSettings.IsDefault = 0  
  
 UPDATE SMTPEmailSettings  
 SET SMTPEmailSettings.IsDefault = 1  
 WHERE SMTPEmailSettings.SmtpProviderId = @SmtpProviderId  
END  
  
GO
/****** Object:  StoredProcedure [dbo].[Usp_SupportBugListGrid_LastSevenDays]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_SupportBugListGrid_LastSevenDays]                                            
                                    
@page INT,                                        
@pageSize INT,                           
@UserId INT                            
as                                        
begin                                        
                  
 declare @lastweek datetime                
declare @now datetime                
set @now = getdate()                
set @lastweek = dateadd(day,-7,@now)                                       
                                        
DECLARE @SQLQuery AS NVARCHAR(max)                                        
set @SQLQuery = ''                                        
SET @SQLQuery = @SQLQuery + '                                        
SELECT * FROM                                        
(                                         
                                        
select ROW_NUMBER() OVER (ORDER BY BS.BugId desc) as RowNum,                                        
BS.BugId ,                                        
BS.Summary ,                                        
P.ProjectName ,                                        
PC.ComponentName,                                        
pr.PriorityName,                                        
case when ISNULL(RS.ResolutionId,0) =0 then ''NA'' else rs.Resolution end as Resolution,                                        
s.Severity,                                        
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,                                        
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,                                        
UM.FirstName +'' ''+ SUBSTRING(UM.LastName, 1, 1) as AssignedTo,                              
UMR.FirstName +'' ''+ SUBSTRING(UMR.LastName, 1, 1) as Reportedby,                               
ST.StatusName,                                      
ST.StatusId,                          
CONVERT(varchar(10),bt.ClosedOn,126) as ClosedOn                          
from BugSummary BS                                        
inner join BugTracking bt on BS.BugId = bt.BugId                                        
inner join Projects p on BS.ProjectId = p.ProjectId                                        
inner join Severity S on BS.SeverityId = S.SeverityId                                        
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                                        
inner join Priority pr on BS.PriorityId = pr.PriorityId                                        
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                                        
inner join UserMaster UM on Bt.AssignedTo = UM.UserId                                 
inner join UserMaster UMR on bt.CreatedBy = UMR.UserId                                  
inner join Status St on Bt.StatusId = St.StatusId where 1=1'                                        
                 
SET @SQLQuery = @SQLQuery + 'and  convert(VARCHAR(10),isnull(bt.ModifiedOn,bt.CreatedOn),23) >=  '''+ convert(VARCHAR(10),@lastweek,23) + ''''                    
              
            
                     
 IF(@UserId is not null and @UserId>0)                          
 begin                          
    
  SET @SQLQuery = @SQLQuery + '  and BS.CreatedBy in (select UserId from AssignedProject where RoleId in (9,10)) and  bs.ProjectId in (select ProjectId from AssignedProject where RoleId in (9,10) and UserId = ' + convert(VARCHAR(50),@UserId) + ') '      
 end               
              
        
SET @SQLQuery = @SQLQuery + '  ) A                                        
WHERE A.RowNum                                        
BETWEEN (((' + convert(VARCHAR(10),@page) + ' - 1) * ' + convert(VARCHAR(10),@pageSize) + ') + 1) AND (' + convert(VARCHAR(10),@page) + ' * ' + convert(VARCHAR(10),@pageSize) + ')                                        
ORDER BY A.RowNum;'                                        
           
print @SQLQuery                                        
EXEC (@SQLQuery)                                        
                                        
                 
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_SupportBugListGridCount_LastSevenDays]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_SupportBugListGridCount_LastSevenDays]                   
   @UserId INT                   
as                  
begin                  
                  
declare @lastweek datetime          
declare @now datetime          
set @now = getdate()          
set @lastweek = dateadd(day,-7,@now)               
          
DECLARE @SQLQuery AS NVARCHAR(max)                  
set @SQLQuery = ''                  
SET @SQLQuery = @SQLQuery + '                  
                  
select  count(1) as ctn                  
from BugSummary BS                  
inner join BugTracking bt on BS.BugId = bt.BugId                  
inner join Projects p on BS.ProjectId = p.ProjectId                  
inner join Severity S on BS.SeverityId = S.SeverityId                  
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                  
inner join Priority pr on BS.PriorityId = pr.PriorityId                  
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                  
inner join UserMaster UM on Bt.AssignedTo = UM.UserId                   
inner join Status St on Bt.StatusId = St.StatusId where 1=1'                  
           
SET @SQLQuery = @SQLQuery + 'and  convert(VARCHAR(10),isnull(bt.ModifiedOn,bt.CreatedOn),23) >=  '''+ convert(VARCHAR(10),@lastweek,23) + ''''                 
          
 IF(@UserId is not null and @UserId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  bs.ProjectId in (select ProjectId from AssignedProject where UserId = ' + convert(VARCHAR(50),@UserId) + ') '                      
 end         
                      
               
SET @SQLQuery = @SQLQuery + ' '                  
                  
print @SQLQuery                  
EXEC (@SQLQuery)                  
                  
                  
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_SupportLeadBugListGrid]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_SupportLeadBugListGrid]                               
@ProjectId int = null,                    
@PriorityId int= null,                    
@SeverityId int= null,                    
@StatusId int = null,                    
@AssignedtoId int = null,           
@ProjectComponentId int = null,                    
@page INT,                    
@pageSize INT ,    
@ReportersUserId INT      
as                    
begin                    
                    
                    
DECLARE @SQLQuery AS NVARCHAR(max)                    
set @SQLQuery = ''                    
SET @SQLQuery = @SQLQuery + '                    
SELECT * FROM                    
(                     
                    
select ROW_NUMBER() OVER (ORDER BY BS.BugId desc) as RowNum,                    
BS.BugId ,                    
BS.Summary ,                    
P.ProjectName ,                    
PC.ComponentName,                    
pr.PriorityName,                    
case when ISNULL(RS.ResolutionId,0) =0 then ''NA'' else rs.Resolution end as Resolution,                    
s.Severity,                    
CONVERT(varchar(10),BS.CreatedOn,126) as CreatedOn,                    
CONVERT(varchar(10),BS.ModifiedOn,126) as ModifiedOn,                    
UM.FirstName +'' ''+ SUBSTRING(UM.LastName, 1, 1)  as AssignedTo,                   
ST.StatusName,                  
ST.StatusId,            
CONVERT(varchar(10),bt.ClosedOn,126) as ClosedOn ,
UMR.FirstName +'' ''+ SUBSTRING(UMR.LastName, 1, 1)as Reportedby,
TE.TestedOn,
TE.TestedOnId
from BugSummary BS                    
inner join BugTracking bt on BS.BugId = bt.BugId                    
inner join Projects p on BS.ProjectId = p.ProjectId                    
inner join Severity S on BS.SeverityId = S.SeverityId                    
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId                    
inner join Priority pr on BS.PriorityId = pr.PriorityId                    
left join Resolution RS on bt.ResolutionId = RS.ResolutionId                    
inner join UserMaster UM on Bt.AssignedTo = UM.UserId 
inner join UserMaster UMR on BS.CreatedBy = UMR.UserId   
inner join Status St on Bt.StatusId = St.StatusId 
inner join TestedEnvironment TE on BS.TestedOnId = TE.TestedOnId
where bt.CreatedBy in (select UserId from AssignedProject where ProjectId = '''+ convert(VARCHAR(10),@ProjectId) + '''and RoleId in (9,10))'                    
                    
if(@ProjectId is not null and @ProjectId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.ProjectId = ' + convert(VARCHAR(50),@ProjectId) + ' '                      
 end                     
                    
if(@PriorityId is not null and @PriorityId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.PriorityId = ' + convert(VARCHAR(50),@PriorityId) + ' '                      
 end                     
                    
 if(@SeverityId is not null and @SeverityId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.SeverityId = ' + convert(VARCHAR(50),@SeverityId) + ' '                      
 end                     
                    
 if(@StatusId is not null and @StatusId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  Bt.StatusId = ' + convert(VARCHAR(50),@StatusId) + ' '                      
 end         
         
  if(@AssignedtoId is not null and @AssignedtoId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  Bt.AssignedTo = ' + convert(VARCHAR(50),@AssignedtoId) + ' '                      
 end             
                     
 if(@ProjectComponentId is not null and @ProjectComponentId>0)                    
 begin                    
 SET @SQLQuery = @SQLQuery + '                     
  and  BS.ProjectComponentId = ' + convert(VARCHAR(50),@ProjectComponentId) + ' '                      
 end                     
    
 IF(@ReportersUserId is not null and @ReportersUserId>0)                    
 begin                     SET @SQLQuery = @SQLQuery + '                     
  and  bt.CreatedBy = ' + convert(VARCHAR(50),@ReportersUserId) + ' '                      
 end         
     
SET @SQLQuery = @SQLQuery + '  ) A                    
WHERE A.RowNum                    
BETWEEN (((' + convert(VARCHAR(10),@page) + ' - 1) * ' + convert(VARCHAR(10),@pageSize) + ') + 1) AND (' + convert(VARCHAR(10),@page) + ' * ' + convert(VARCHAR(10),@pageSize) + ')                    
ORDER BY A.RowNum;'                    
                    
print @SQLQuery                    
EXEC (@SQLQuery)                    
                    
                    
end 
GO
/****** Object:  StoredProcedure [dbo].[Usp_SupportLeadBugListGridCount]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_SupportLeadBugListGridCount]         
@ProjectId int = null,        
@PriorityId int= null,        
@SeverityId int= null,        
@StatusId int = null,        
@ProjectComponentId int = NULL,    
@ReportersUserId INT    
as        
begin        
        
        
DECLARE @SQLQuery AS NVARCHAR(max)        
set @SQLQuery = ''        
SET @SQLQuery = @SQLQuery + '        
        
select  count(1) as ctn        
from BugSummary BS        
inner join BugTracking bt on BS.BugId = bt.BugId        
inner join Projects p on BS.ProjectId = p.ProjectId        
inner join Severity S on BS.SeverityId = S.SeverityId        
inner join ProjectComponent pc on BS.ProjectComponentId = pc.ProjectComponentId        
inner join Priority pr on BS.PriorityId = pr.PriorityId        
left join Resolution RS on bt.ResolutionId = RS.ResolutionId        
inner join UserMaster UM on Bt.AssignedTo = UM.UserId         
inner join Status St on Bt.StatusId = St.StatusId
where bt.CreatedBy in (select UserId from AssignedProject where ProjectId = '''+ convert(VARCHAR(10),@ProjectId) + '''and RoleId in (9,10))'                
        
if(@ProjectId is not null and @ProjectId>0)        
 begin        
 SET @SQLQuery = @SQLQuery + '         
  and  BS.ProjectId = ' + convert(VARCHAR(50),@ProjectId) + ' '          
 end         
        
if(@PriorityId is not null and @PriorityId>0)        
 begin        
 SET @SQLQuery = @SQLQuery + '         
  and  BS.PriorityId = ' + convert(VARCHAR(50),@PriorityId) + ' '          
 end         
        
 if(@SeverityId is not null and @SeverityId>0)        
 begin        
 SET @SQLQuery = @SQLQuery + '         
  and  BS.SeverityId = ' + convert(VARCHAR(50),@SeverityId) + ' '          
 end         
        
 if(@StatusId is not null and @StatusId>0)        
 begin        
 SET @SQLQuery = @SQLQuery + '         
  and  Bt.StatusId = ' + convert(VARCHAR(50),@StatusId) + ' '          
 end         
        
 if(@ProjectComponentId is not null and @ProjectComponentId>0)        
 begin        
 SET @SQLQuery = @SQLQuery + '         
  and  BS.ProjectComponentId = ' + convert(VARCHAR(50),@ProjectComponentId) + ' '          
 end         
    
 IF(@ReportersUserId is not null and @ReportersUserId>0)                
 begin                
 SET @SQLQuery = @SQLQuery + '                 
  and  bt.CreatedBy = ' + convert(VARCHAR(50),@ReportersUserId) + ' '                  
 end          
     
SET @SQLQuery = @SQLQuery + ' '        
        
print @SQLQuery        
EXEC (@SQLQuery)        
        
        
end        
        
--- exec Usp_BugListGridCount 6,1,1,3,1,1,10  
GO
/****** Object:  StoredProcedure [dbo].[Usp_TeamDetailsbyProjectId]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[Usp_TeamDetailsbyProjectId]            
@ProjectId INT              
as            
            
begin            
            
SELECT CONVERT(VARCHAR(10),Ap.UserId)   AS UserId,                  
UMR.FirstName +' '+ UMR.LastName as FullName,              
DM.Designation as AssignedRole ,            
UMR.Gender,            
  convert(varchar, AP.CreatedOn, 106) as AssignedProjectOn            
FROM dbo.AssignedProject Ap                  
inner join UserMaster UMR on Ap.UserId = UMR.UserId                   
inner join SavedAssignedRoles SAR on Ap.UserId = SAR.UserId                   
inner join DesignationMaster DM on UMR.DesignationId = DM.DesignationId                    
WHERE  AP.ProjectId =@ProjectId    and ap.Status = 1   
ORDER BY UMR.FirstName asc    
            
end
GO
/****** Object:  StoredProcedure [dbo].[Usp_UpdateBugsStatus]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_UpdateBugsStatus]          
 @BugId BIGINT,          
 @StatusId int          
AS            
BEGIN            
            
  UPDATE dbo.BugTracking             
        SET           
        BugTracking.StatusId =@StatusId           
        WHERE BugTracking.BugId = @BugId            
              
END 
GO
/****** Object:  StoredProcedure [dbo].[Usp_UpdateIsFirstLoginStatus]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_UpdateIsFirstLoginStatus]    
    @UserId BIGINT  
AS    
BEGIN    
     
	   UPDATE UserMaster    
        SET UserMaster.IsFirstLogin=0,    
            UserMaster.IsFirstLoginDate = GETDATE() 
        WHERE UserMaster.UserId = @UserId;    


 
END; 
GO
/****** Object:  StoredProcedure [dbo].[USP_UpdatePasswordandVerificationStatus]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Proc [dbo].[USP_UpdatePasswordandVerificationStatus]  
 @UserId  bigint  ,  
 @GeneratedToken varchar(70),  
 @Password varchar(150)  
as  
begin  
  
Update [ResetPasswordVerification]  
Set VerificationStatus =1,  
VerificationDate =getdate(),  
Status = 0  
where GeneratedToken =@GeneratedToken and Userid= @UserId  
  
Update UserMaster  
Set PasswordHash =@Password  
where UserId =@UserId  
  
end  
  
  
GO
/****** Object:  StoredProcedure [dbo].[Usp_ValidateNotice]    Script Date: 28-05-2022 2.27.19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Usp_ValidateNotice]
    @fromdatetime DATETIME,
    @todatetime DATETIME
AS
BEGIN

    IF (
       (
           SELECT COUNT(1)
           FROM Notice N
               INNER JOIN NoticeDetails ND
                   ON N.NoticeId = ND.NoticeId
           WHERE @fromdatetime 
                 BETWEEN N.NoticeStart AND N.NoticeEnd
				
				or @todatetime BETWEEN N.NoticeStart AND N.NoticeEnd
                 AND N.Status = 1
       ) > 0
       )
    BEGIN
        SELECT 1;
    END;
    ELSE
    BEGIN
        SELECT 0;
    END;
END;
GO
USE [master]
GO
ALTER DATABASE [BugPointDB] SET  READ_WRITE 
GO
