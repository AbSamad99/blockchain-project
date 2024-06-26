// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MessageBoard {
    struct Post {
        string title;
        string body;
        address author;
        uint256 commentsCount;
    }

    struct Comment {
        uint256 postId;
        string body;
        address author;
    }

    struct User {
        string name;
        uint256[] postIds;
    }

    mapping(address => User) users;
    uint256 userCount;
    Post[] posts;
    Comment[] comments;

    modifier requireSignup() {
        require(
            bytes(users[msg.sender].name).length > 0,
            "Please sign up first!"
        );
        _;
    }

    modifier verifyTitleLength(string memory title) {
        require(
            bytes(title).length > 5 && bytes(title).length < 30,
            "Title must be between 5 and 30 characters in length"
        );
        _;
    }

    modifier verifyBodyLength(string memory body) {
        require(
            bytes(body).length > 10 && bytes(body).length < 150,
            "Body must be between 10 and 150 characters in length"
        );
        _;
    }

    modifier verifyPostExists(uint256 postId) {
        require(posts.length > postId, "Post does not exist");
        _;
    }

    modifier verifyPostOwnerShip(uint256 postId) {
        require(
            posts[postId].author == msg.sender,
            "You are not the author of this post!"
        );
        _;
    }

    modifier verifyCommentExists(uint256 commentId) {
        require(comments.length > commentId, "comment does not exist");
        _;
    }

    modifier verifyCommentOwnerShip(uint256 commentId) {
        require(
            comments[commentId].author == msg.sender,
            "You are not the author of this comment!"
        );
        _;
    }

    function signUp(string memory name) public {
        require(
            bytes(name).length >= 4,
            "Name must be at least 5 characters long!"
        );
        require(
            bytes(users[msg.sender].name).length == 0,
            "User already registered"
        );

        users[msg.sender].name = name;
        userCount++;
    }

    function deleteAccount() public requireSignup {
        delete users[msg.sender];
        userCount--;
    }

    function createPost(
        string memory title,
        string memory body
    ) public requireSignup verifyTitleLength(title) verifyBodyLength(body) {
        users[msg.sender].postIds.push(posts.length);
        Post memory post;
        post.title = title;
        post.body = body;
        post.author = msg.sender;
        posts.push(post);
    }

    function getPost(
        uint256 postId
    ) public view verifyPostExists(postId) returns (Post memory) {
        return posts[postId];
    }

    function getAllPostsByAddress(
        address author
    ) public view returns (Post[] memory) {
        uint256 length = users[author].postIds.length;
        Post[] memory _posts = new Post[](length);
        for (uint256 i = 0; i < length; i++) {
            _posts[i] = posts[users[author].postIds[i]];
        }
        return _posts;
    }

    function getAllPosts() public view returns (Post[] memory) {
        return posts;
    }

    function updatePost(
        uint256 postId,
        string memory title,
        string memory body
    )
        public
        requireSignup
        verifyTitleLength(title)
        verifyBodyLength(body)
        verifyPostExists(postId)
        verifyPostOwnerShip(postId)
    {
        Post storage post = posts[postId];
        post.title = title;
        post.body = body;
    }

    // function deletePost(uint256 postId)
    //     public
    //     requireSignup
    //     verifyPostExists(postId)
    //     verifyPostOwnerShip(postId)
    // {
    //     Post memory post;
    //     posts[postId] = post;
    // }

    function createPostComment(
        uint256 postId,
        string memory body
    ) public requireSignup verifyBodyLength(body) verifyPostExists(postId) {
        Comment memory comment;
        comment.postId = postId;
        comment.body = body;
        comment.author = msg.sender;
        comments.push(comment);
        posts[postId].commentsCount++;
    }

    function getPostComment(
        uint256 commentId
    ) public view verifyCommentExists(commentId) returns (Comment memory) {
        return comments[commentId];
    }

    function getCommentsByPost(
        uint256 postId
    ) public view verifyPostExists(postId) returns (Comment[] memory) {
        if (posts[postId].commentsCount > 0) {
            Comment[] memory _comments = new Comment[](
                posts[postId].commentsCount
            );
            uint256 _commentIndex = 0;
            for (uint256 i; i < comments.length; i++) {
                if (comments[i].postId == postId) {
                    _comments[_commentIndex] = comments[i];
                    _commentIndex++;
                }
            }
            return _comments;
        } else {
            Comment[] memory _comments = new Comment[](1);
            return _comments;
        }
    }

    function updatePostComment(
        uint256 commentId,
        string memory body
    )
        public
        requireSignup
        verifyBodyLength(body)
        verifyCommentExists(commentId)
        verifyCommentOwnerShip(commentId)
    {
        Comment memory comment;
        comment.body = body;
        comments.push(comment);
    }

    // function deletePostComment(uint256 commentId)
    //     public
    //     requireSignup
    //     verifyCommentExists(commentId)
    //     verifyCommentOwnerShip(commentId)
    // {
    //     posts[comments[commentId].postId].commentsCount--;
    //     comments[commentId] = comments[comments.length-1];
    //     comments.pop();
    // }
}
