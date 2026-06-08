<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>DevSecOps POC Live App</title>
    <style>
        body {
            background-color: ${bgColor != null ? bgColor : '#ffffff'};
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .container {
            text-align: center;
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 DevSecOps Automated Pipeline</h1>
        <p>Kubernetes Deployment Status: <strong>Online</strong></p>
        <p>Hello All</p>
    </div>
</body>
</html>
