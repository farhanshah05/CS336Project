<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="com.cs336.pkg.ApplicationDB"%>
<!DOCTYPE html>
<html>
<head>
  <title>Customer Dashboard</title>
  <script>
      function clearFiltersAndReload() {
          document.getElementById("searchKeyword").value = "";
          document.forms[0].submit(); // Submit the form with an empty search field
      }
      function toggleSearchFields(mode) {
          document.getElementById("searchByLine").style.display = mode === "line" ? "block" : "none";
          document.getElementById("searchByOriginDestination").style.display = mode === "originDestination" ? "block" : "none";
          document.getElementById("searchMode").value = mode;
      }
      function resetFilters() {
          window.location.href = "CustomerDashboard.jsp"; // Reload the page to reset filters
      }
  </script>
</head>
<body>
  <%
      String user = (String) session.getAttribute("user");
      String role = (String) session.getAttribute("role");
      if (user == null || !"customer".equals(role)) {
          response.sendRedirect("Login.jsp");
          return;
      }
      // Initialize database connection
      ApplicationDB db = new ApplicationDB();
      Connection con = null;
  %>
  <h1>Welcome, <%= user %>!</h1>
  <h2>Customer Dashboard</h2>
  <form action="Logout.jsp" method="GET" style="margin-top: 20px;">
	    <button type="submit">Logout</button>
	</form><br>
  <!-- Search Train Schedules -->
  <h3>Search Train Schedules</h3>
  <div>
      <button type="button" onclick="toggleSearchFields('line')">Search by Transit Line</button>
      <button type="button" onclick="toggleSearchFields('originDestination')">Search by Origin and Destination</button>
  </div>
  <form method="GET">
      <input type="hidden" id="searchMode" name="searchMode" value="line">
      <!-- Search by Transit Line -->
      <div id="searchByLine" style="display: block;">
          <label for="lineID">Select Transit Line:</label>
          <select id="lineID" name="lineID">
              <option value="">-- Select Line --</option>
              <%
                  try {
                      con = db.getConnection();
                      Statement stmt = con.createStatement();
                      ResultSet rs = stmt.executeQuery("SELECT LineID, LineName FROM TransitLines");
                      while (rs.next()) {
              %>
                          <option value="<%= rs.getInt("LineID") %>"
                              <%= request.getParameter("lineID") != null && request.getParameter("lineID").equals(String.valueOf(rs.getInt("LineID"))) ? "selected" : "" %>>
                              <%= rs.getString("LineName") %>
                          </option>
              <%
                      }
                  } catch (SQLException e) {
                      out.println("<p>Error loading transit lines: " + e.getMessage() + "</p>");
                  } finally {
                      if (con != null) try { con.close(); } catch (SQLException ignored) {}
                  }
              %>
          </select>
      </div>
      <!-- Search by Origin and Destination -->
      <div id="searchByOriginDestination" style="display: none;">
          <label for="originStation">Select Origin Station:</label>
          <select id="originStation" name="originStation">
              <option value="">-- Select Station --</option>
              <%
                  try {
                      con = db.getConnection();
                      Statement stmt = con.createStatement();
                      ResultSet rs = stmt.executeQuery("SELECT StationID, StationName FROM Stations");
                      while (rs.next()) {
              %>
                          <option value="<%= rs.getInt("StationID") %>"
                              <%= request.getParameter("originStation") != null && request.getParameter("originStation").equals(String.valueOf(rs.getInt("StationID"))) ? "selected" : "" %>>
                              <%= rs.getString("StationName") %>
                          </option>
              <%
                      }
                  } catch (SQLException e) {
                      out.println("<p>Error loading stations: " + e.getMessage() + "</p>");
                  } finally {
                      if (con != null) try { con.close(); } catch (SQLException ignored) {}
                  }
              %>
          </select>
          <label for="destinationStation">Select Destination Station:</label>
          <select id="destinationStation" name="destinationStation">
              <option value="">-- Select Station --</option>
              <%
                  try {
                      con = db.getConnection();
                      Statement stmt = con.createStatement();
                      ResultSet rs = stmt.executeQuery("SELECT StationID, StationName FROM Stations");
                      while (rs.next()) {
              %>
                          <option value="<%= rs.getInt("StationID") %>"
                              <%= request.getParameter("destinationStation") != null && request.getParameter("destinationStation").equals(String.valueOf(rs.getInt("StationID"))) ? "selected" : "" %>>
                              <%= rs.getString("StationName") %>
                          </option>
              <%
                      }
                  } catch (SQLException e) {
                      out.println("<p>Error loading stations: " + e.getMessage() + "</p>");
                  } finally {
                      if (con != null) try { con.close(); } catch (SQLException ignored) {}
                  }
              %>
          </select>
      </div>
      <!-- Travel Date -->
      <label for="travelDate">Select Date of Travel:</label>
      <select id="travelDate" name="travelDate">
          <option value="">-- Select Date --</option>
          <%
              try {
                  con = db.getConnection();
                  Statement stmt = con.createStatement();
                  ResultSet rs = stmt.executeQuery("SELECT DISTINCT DATE(DepartureTime) AS TravelDate FROM TrainStops ORDER BY TravelDate");
                  while (rs.next()) {
          %>
                      <option value="<%= rs.getString("TravelDate") %>"
                          <%= request.getParameter("travelDate") != null && request.getParameter("travelDate").equals(rs.getString("TravelDate")) ? "selected" : "" %>>
                          <%= rs.getString("TravelDate") %>
                      </option>
          <%
                  }
              } catch (SQLException e) {
                  out.println("<p>Error loading travel dates: " + e.getMessage() + "</p>");
              } finally {
                  if (con != null) try { con.close(); } catch (SQLException ignored) {}
              }
          %>
      </select>
      <label for="scheduleSort">Sort By:</label>
      <select id="scheduleSort" name="scheduleSort">
          <option value="">-- Select --</option>
          <option value="departure">Departure Time</option>
          <option value="arrival">Arrival Time</option>
          <option value="lineName">Line Name</option>
          <option value="fare">Total Fare</option>
      </select>
      <button type="submit">Search</button>
      <button type="button" onclick="resetFilters()">View All Results</button>
  </form>
  <!-- Results Table -->
     <h2>Results:</h2>
   <table border="1">
       <tr>
           <th>Transit Line</th>
           <th>Origin Station</th>
           <th>Destination Station</th>
           <th>Departure Time</th>
           <th>Arrival Time</th>
           <th>Total Fare</th>
       </tr>
       <%
           String searchMode = request.getParameter("searchMode");
           String lineID = request.getParameter("lineID");
           String travelDate = request.getParameter("travelDate");
           String originStation = request.getParameter("originStation");
           String destinationStation = request.getParameter("destinationStation");
           String scheduleSortOption = request.getParameter("scheduleSort");
           String scheduleOrderByClause = "";
           if ("departure".equals(scheduleSortOption)) {
               scheduleOrderByClause = "ORDER BY ts_origin.DepartureTime";
           } else if ("arrival".equals(scheduleSortOption)) {
               scheduleOrderByClause = "ORDER BY ts_dest.ArrivalTime";
           } else if ("lineName".equals(scheduleSortOption)) {
               scheduleOrderByClause = "ORDER BY tl.LineName";
           } else if ("fare".equals(scheduleSortOption)) {
               scheduleOrderByClause = "ORDER BY TotalFare DESC";
           }
           try {
               con = db.getConnection();
               String query =
                   "SELECT tl.LineName, s1.StationName AS OriginStation, s2.StationName AS DestinationStation, " +
                   "ts_origin.DepartureTime, ts_dest.ArrivalTime, " +
                   "(SELECT SUM(r.TotalFare) FROM Reservations r WHERE r.LineID = tl.LineID) AS TotalFare " +
                   "FROM TrainStops ts_origin " +
                   "JOIN TrainStops ts_dest ON ts_origin.ScheduleID = ts_dest.ScheduleID AND ts_origin.DepartureTime < ts_dest.ArrivalTime " +
                   "JOIN TrainSchedules sch ON ts_origin.ScheduleID = sch.ScheduleID " +
                   "JOIN TransitLines tl ON sch.LineID = tl.LineID " +
                   "JOIN Stations s1 ON ts_origin.StationID = s1.StationID " +
                   "JOIN Stations s2 ON ts_dest.StationID = s2.StationID " +
                   "WHERE 1=1 ";
               if (travelDate != null && !travelDate.isEmpty()) {
                   query += "AND DATE(ts_origin.DepartureTime) = ? ";
               }
               if ("line".equals(searchMode) && lineID != null && !lineID.isEmpty()) {
                   query += "AND tl.LineID = ? ";
               }
               if ("originDestination".equals(searchMode)) {
                   if (originStation != null && !originStation.isEmpty()) query += "AND s1.StationID = ? ";
                   if (destinationStation != null && !destinationStation.isEmpty()) query += "AND s2.StationID = ? ";
               }
               query += scheduleOrderByClause;
               PreparedStatement pstmt = con.prepareStatement(query);
               int paramIndex = 1;
               if (travelDate != null && !travelDate.isEmpty()) pstmt.setString(paramIndex++, travelDate);
               if ("line".equals(searchMode) && lineID != null && !lineID.isEmpty()) pstmt.setInt(paramIndex++, Integer.parseInt(lineID));
               if ("originDestination".equals(searchMode)) {
                   if (originStation != null && !originStation.isEmpty()) pstmt.setInt(paramIndex++, Integer.parseInt(originStation));
                   if (destinationStation != null && !destinationStation.isEmpty()) pstmt.setInt(paramIndex++, Integer.parseInt(destinationStation));
               }
               ResultSet rs = pstmt.executeQuery();
               boolean hasResults = false;
               while (rs.next()) {
                   hasResults = true;
       %>
                   <tr>
                       <td><%= rs.getString("LineName") %></td>
                       <td><%= rs.getString("OriginStation") %></td>
                       <td><%= rs.getString("DestinationStation") %></td>
                       <td><%= rs.getTimestamp("DepartureTime") %></td>
                       <td><%= rs.getTimestamp("ArrivalTime") %></td>
                       <td><%= rs.getDouble("TotalFare") %></td>
                   </tr>
       <%
               }
               if (!hasResults) {
       %>
                   <tr>
                       <td colspan="6">No results found for the selected criteria.</td>
                   </tr>
       <%
               }
           } catch (SQLException e) {
               out.println("<p>Error retrieving train schedules: " + e.getMessage() + "</p>");
           } finally {
               if (con != null) try { con.close(); } catch (SQLException ignored) {}
           }
       %>
   </table>
  <!-- Browse Questions and Answers -->
  <h3>Browse Questions and Answers</h3>
  <form method="GET">
      <label for="searchKeyword">Search Questions:</label>
      <input type="text" id="searchKeyword" name="searchKeyword" value="<%= request.getParameter("searchKeyword") != null ? request.getParameter("searchKeyword") : "" %>">
      <button type="submit">Search</button>
      <button type="button" onclick="clearFiltersAndReload()">Clear</button>
  </form>
  <table border="1">
      <tr>
          <th>Question</th>
          <th>Answer</th>
          <th>Status</th>
          <th>Actions</th>
      </tr>
      <%
          String searchKeyword = request.getParameter("searchKeyword");
          PreparedStatement pstmt = null;
          ResultSet rsQuestions = null;
          try {
              con = db.getConnection();
              String query =
                  "SELECT m1.Message AS Question, " +
                  "(SELECT m2.Message FROM Messages m2 WHERE m2.ConversationID = m1.ConversationID AND m2.SenderID != m1.SenderID ORDER BY m2.Timestamp DESC LIMIT 1) AS Answer, " +
                  "c.ConversationID, c.Status " +
                  "FROM Messages m1 " +
                  "JOIN Conversations c ON m1.ConversationID = c.ConversationID " +
                  "WHERE c.CustomerID = (SELECT CustomerID FROM Customers WHERE Username = ?) AND m1.SenderID = c.CustomerID " +
                  "AND m1.Timestamp = (SELECT MIN(Timestamp) FROM Messages WHERE ConversationID = c.ConversationID) ";
              if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                  query += "AND m1.Message LIKE ?";
              }
              pstmt = con.prepareStatement(query);
              pstmt.setString(1, user);
              if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                  pstmt.setString(2, "%" + searchKeyword + "%");
              }
              rsQuestions = pstmt.executeQuery();
              boolean hasResults = false;
              while (rsQuestions.next()) {
                  hasResults = true;
      %>
                  <tr>
                      <td><%= rsQuestions.getString("Question") %></td>
                      <td><%= rsQuestions.getString("Answer") != null ? rsQuestions.getString("Answer") : "Not answered yet" %></td>
                      <td><%= rsQuestions.getString("Status") %></td>
                      <td>
                          <form action="ViewConversation.jsp" method="GET" style="display:inline;">
                              <input type="hidden" name="conversationID" value="<%= rsQuestions.getInt("ConversationID") %>">
                              <button type="submit">View</button>
                          </form>
                      </td>
                  </tr>
      <%
              }
              if (!hasResults) {
      %>
                  <tr>
                      <td colspan="4">No questions found.</td>
                  </tr>
      <%
              }
          } catch (SQLException e) {
              out.println("<p>Error fetching questions: " + e.getMessage() + "</p>");
          } finally {
              if (rsQuestions != null) try { rsQuestions.close(); } catch (SQLException ignored) {}
              if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
              if (con != null) try { con.close(); } catch (SQLException ignored) {}
          }
      %>
  </table>
  <!-- Send a Question -->
  <h3>Send a Question</h3>
  <form method="POST">
      <label for="question">Your Question:</label><br>
      <textarea id="question" name="question" rows="4" cols="50" required></textarea><br>
      <button type="submit">Submit</button>
  </form>
  <%
      if ("POST".equalsIgnoreCase(request.getMethod())) {
          String question = request.getParameter("question");
          if (question != null && !question.trim().isEmpty()) {
              try {
                  con = db.getConnection();
                  // Assign a default employee if EmployeeID is required
                  int defaultEmployeeID = 1; // Replace with an actual employee ID from your database
                  // Start a new conversation
                  int conversationID = 0;
                  pstmt = con.prepareStatement(
                      "INSERT INTO Conversations (CustomerID, EmployeeID, Status) VALUES ((SELECT CustomerID FROM Customers WHERE Username = ?), ?, 'open')",
                      Statement.RETURN_GENERATED_KEYS
                  );
                  pstmt.setString(1, user);
                  pstmt.setInt(2, defaultEmployeeID);
                  pstmt.executeUpdate();
                  // Get the generated Conversation ID
                  rsQuestions = pstmt.getGeneratedKeys();
                  if (rsQuestions.next()) {
                      conversationID = rsQuestions.getInt(1);
                  }
                  // Insert the question as a message
                  pstmt = con.prepareStatement(
                      "INSERT INTO Messages (ConversationID, SenderID, ReceiverID, Message) VALUES (?, (SELECT CustomerID FROM Customers WHERE Username = ?), ?, ?)"
                  );
                  pstmt.setInt(1, conversationID);
                  pstmt.setString(2, user);
                  pstmt.setInt(3, defaultEmployeeID);
                  pstmt.setString(4, question);
                  pstmt.executeUpdate();
                  out.println("<p>Question submitted successfully. <a href='CustomerDashboard.jsp'>Go back</a></p>");
              } catch (SQLException e) {
                  out.println("<p>Error submitting question: " + e.getMessage() + "</p>");
              } finally {
                  if (rsQuestions != null) try { rsQuestions.close(); } catch (SQLException ignored) {}
                  if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
                  if (con != null) try { con.close(); } catch (SQLException ignored) {}
              }
          } else {
              out.println("<p>Error: Question cannot be empty.</p>");
          }
      }
  %>
</body>
</html>
